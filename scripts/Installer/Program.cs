/*
 
Flix Installer 
Build date: 2024/07/23
© 2024 Gnayoah. All rights reserved.

*/

/*
 打包指令： 
 dotnet publish -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -p:PublishTrimmed=true -o ./publish

 更新方式：
 替换 Installer/flix.zip 压缩包，安装器自带卸载

 请勿删除和替换 installer.zip 和其他资源文件，避免出错
 */



using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Reflection;

class Program
{
    static void Main()
    {
        string desktopPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
        string desktopFlixPath = Path.Combine(desktopPath, "Flix");
       

        // Delete the Flix file on the desktop if it exists
        if (File.Exists(desktopFlixPath))
        {
            try
            {
                File.Delete(desktopFlixPath);
                Console.WriteLine("Existing Flix file on desktop has been deleted.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to delete existing Flix file on desktop: {ex.Message}");
                return;
            }
        }

       

        string localAppDataPath = Path.GetTempPath();
        string targetFolderPath = Path.Combine(localAppDataPath, "Flix");
        string installerZipPath = Path.Combine(targetFolderPath, "installer.zip");
        string flixZipPath = Path.Combine(targetFolderPath, "flix.zip");
        string iconFilePath = Path.Combine(targetFolderPath, "setting.ico");



        Directory.CreateDirectory(targetFolderPath);
        if (!ExtractEmbeddedResource("Installer.installer.zip", targetFolderPath))
        {
            Console.WriteLine("Failed to extract the ZIP file.");
            return;
        }
        if (!CopyEmbeddedResourceToFile("Installer.flix.zip", flixZipPath))
        {
            Console.WriteLine("Failed to copy the flix.zip file.");
            return;
        }
        if (!CopyEmbeddedResourceToFile("Installer.setting.ico", iconFilePath))
        {
            Console.WriteLine("Failed to copy the lo.ico file.");
            return;
        }
        if (!AddUninstallerToZip(flixZipPath, "Installer.uninstall.exe"))
        {
            Console.WriteLine("Failed to add uninstaller to flix.zip.");
            return;
        }
        string installerPath = Path.Combine(targetFolderPath, "Flix Installer.exe");
        if (File.Exists(installerPath))
        {
            if (TerminateProcess("flix"))
            {
                RunInstallerWithPowerShell(installerPath);
            }
            else
            {
                Console.WriteLine("Failed to terminate flix process or delete existing Flix files and directories.");
            }
        }
        else
        {
            Console.WriteLine("Installer file not found.");
        }
        DirectoryInfo directoryInfo = new DirectoryInfo(targetFolderPath);
        directoryInfo.Attributes |= FileAttributes.Hidden;
        Console.WriteLine("Installation files have been extracted and flix.zip has been copied. The folder is now hidden.");
    }

    static bool ExtractEmbeddedResource(string resourceName, string extractionPath)
    {
        Assembly assembly = Assembly.GetExecutingAssembly();
        using (Stream resourceStream = assembly.GetManifestResourceStream(resourceName))
        {
            if (resourceStream == null)
            {
                Console.WriteLine("Resource not found.");
                return false;
            }
            using (ZipArchive archive = new ZipArchive(resourceStream, ZipArchiveMode.Read))
            {
                archive.ExtractToDirectory(extractionPath, true);
            }
        }
        return true;
    }

    static bool CopyEmbeddedResourceToFile(string resourceName, string outputPath)
    {
        Assembly assembly = Assembly.GetExecutingAssembly();
        using (Stream resourceStream = assembly.GetManifestResourceStream(resourceName))
        {
            if (resourceStream == null)
            {
                Console.WriteLine("Resource not found.");
                return false;
            }
            using (FileStream fileStream = new FileStream(outputPath, FileMode.Create, FileAccess.Write))
            {
                resourceStream.CopyTo(fileStream);
            }
        }
        return true;
    }

    static bool AddUninstallerToZip(string zipFilePath, string uninstallerResourceName)
    {
        try
        {
            using (FileStream zipToOpen = new FileStream(zipFilePath, FileMode.Open))
            using (ZipArchive archive = new ZipArchive(zipToOpen, ZipArchiveMode.Update))
            {
                ZipArchiveEntry entry = archive.CreateEntry("uninstall.exe");

                using (Stream entryStream = entry.Open())
                using (Stream resourceStream = Assembly.GetExecutingAssembly().GetManifestResourceStream(uninstallerResourceName))
                {
                    if (resourceStream == null)
                    {
                        Console.WriteLine("Uninstaller resource not found.");
                        return false;
                    }
                    resourceStream.CopyTo(entryStream);
                }
            }
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Failed to add uninstaller to zip: {ex.Message}");
            return false;
        }
    }

    static void RunInstallerWithPowerShell(string filePath)
    {
        // PowerShell命令，用于以管理员权限启动指定的exe文件
        string script = $"Start-Process -FilePath \"{filePath}\" -Verb RunAs";
        string escapedArgs = script.Replace("\"", "\\\"");

        var psi = new ProcessStartInfo
        {
            FileName = "powershell",
            Arguments = $"-NoProfile -ExecutionPolicy Bypass -Command \"{escapedArgs}\"",
            UseShellExecute = false,
            CreateNoWindow = true
        };

        try
        {
            var process = Process.Start(psi);
            Console.WriteLine("Installer executed.");
        }
        catch (Exception ex)
        {
            Console.WriteLine("Failed to execute installer: " + ex.Message);
        }
    }

    static bool TerminateProcess(string processName)
    {
        try
        {
            foreach (Process proc in Process.GetProcessesByName(processName))
            {
                proc.Kill();
                proc.WaitForExit();
                Console.WriteLine($"Process {processName} terminated.");
            }
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Failed to terminate process {processName}: " + ex.Message);
            return false;
        }
    }

    static bool DeleteFilesAndDirectoriesWithAdminPrivileges()
    {
        bool needAdminPrivileges = false;
        string[] pathsToDelete = {
            @"C:\Program Files\Flix",
            @"C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Flix.lnk",
         //   Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Desktop), "Flix.lnk")
        };

        foreach (string path in pathsToDelete)
        {
            if (Directory.Exists(path) || File.Exists(path))
            {
                needAdminPrivileges = true;
                break;
            }
        }

        if (!needAdminPrivileges)
        {
            return true;
        }

        // 清理旧版，仅对0.5.0之前版本有效
        string batchFilePath = Path.Combine(Path.GetTempPath(), "delete_flix_files.bat");
        try
        {
            using (StreamWriter writer = new StreamWriter(batchFilePath))
            {
                writer.WriteLine("@echo off");
                writer.WriteLine("rd /s /q \"C:\\Program Files\\Flix\"");
                writer.WriteLine("del /f /q \"C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Flix.lnk\"");
                writer.WriteLine($"del /f /q \"{Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Desktop), "Flix.lnk")}\"");
            }

            ProcessStartInfo psi = new ProcessStartInfo
            {
                FileName = "cmd.exe",
                Arguments = $"/c \"{batchFilePath}\"",
                Verb = "runas",
                UseShellExecute = true,
                CreateNoWindow = true
            };

            Process process = Process.Start(psi);
            process.WaitForExit();

            File.Delete(batchFilePath);

            return process.ExitCode == 0;
        }
        catch (Exception ex)
        {
            Console.WriteLine("Failed to delete files and directories with admin privileges: " + ex.Message);
            return false;
        }
    }
}

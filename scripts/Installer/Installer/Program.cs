/*
 
Flix Installer v1.0
Build date: 2024/05/24
Copyright © 2024 Haoyang. All rights reserved.

*/

/*
 打包指令： 
 dotnet publish -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -p:PublishTrimmed=true -o ./publish

 更新方式：
 替换 Installer/flix.zip 压缩包，不需要再手动添加uninstall.exe了，安装器自带卸载

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
        string localAppDataPath = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
        string targetFolderPath = Path.Combine(localAppDataPath, "Flix");
        string installerZipPath = Path.Combine(targetFolderPath, "installer.zip");
        string flixZipPath = Path.Combine(targetFolderPath, "flix.zip");
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
        string installerPath = Path.Combine(targetFolderPath, "installer.exe");
        if (File.Exists(installerPath))
        {
            if (TerminateProcess("flix") && DeleteFilesAndDirectoriesWithAdminPrivileges())
            {
                RunInstaller(installerPath);
                string roamingFolderPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "Flix", "Flix");
                Directory.CreateDirectory(roamingFolderPath);
                if (CopyEmbeddedResourceToFile("Installer.uninstall.exe", Path.Combine(roamingFolderPath, "uninstall.exe")))
                {
                    Console.WriteLine("Uninstaller has been copied successfully.");
                }
                else
                {
                    Console.WriteLine("Failed to copy the uninstaller.");
                }
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

    static void RunInstaller(string filePath)
    {
        ProcessStartInfo psi = new ProcessStartInfo
        {
            FileName = filePath,
            UseShellExecute = true,
            CreateNoWindow = true,
            WindowStyle = ProcessWindowStyle.Hidden
        };
        try
        {
            Process process = Process.Start(psi);
            process.WaitForExit();
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

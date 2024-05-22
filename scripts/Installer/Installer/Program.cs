
/*
 
Flix Installer v1.0
Build date: 2024/04/29
Copyright © 2024 Haoyang. All rights reserved.

*/

/*
 打包指令： 
 dotnet publish -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -p:PublishTrimmed=true -o ./publish

 更新方式：
 替换 Installer/flix.zip 压缩包，将卸载包添加到压缩包 uninstall/uninstall.exe 位置（后续会将卸载器集成在安装器中，无需手动添加）

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
           RunAsAdmin(installerPath);
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

   static void RunAsAdmin(string filePath)
   {
       string command = $"-Command \"Start-Process '{filePath}' -Verb runAs\"";
       ProcessStartInfo psi = new ProcessStartInfo
       {
           FileName = "powershell",
           Arguments = command,
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
}

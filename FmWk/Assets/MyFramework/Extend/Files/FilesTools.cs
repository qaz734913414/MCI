using System.IO;


namespace MyFramework
{
    /// <summary>
    /// 文件类工具
    /// </summary>
    public static class FilesTools
    {
        #region 文件
        /// <summary>
        /// 判断文件或者路径存在
        /// </summary>
        /// <param name="FilePath"></param>
        /// <returns></returns>
        public static bool IsKeepFileOrDirectory(string Path)
        {
            if (Directory.Exists(Path))
            {
                return true;
            }
            else
            {
                return File.Exists(Path);
            }
        }
        /// <summary>
        /// 读取文件到数组
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        public static byte[] ReadFileToBytes(string Path)
        {
            FileStream fs = new FileStream(Path, FileMode.Open);
            long size = fs.Length;
            byte[] array = new byte[size];
            fs.Read(array, 0, array.Length);
            fs.Close();
            return array;
        }
        /// <summary>
        /// 读取文件到字符串
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        public static string ReadFileToStr(string Path)
        {
            if (File.Exists(Path))
            {
                return File.ReadAllText(Path);
            }
            else
            {
                LoggerHelper.Error("文件不存在:" + Path);
                return string.Empty;
            }
        }
        /// <summary>
        /// 写入文件到目标目录
        /// </summary>
        /// <param name="_FilePath"></param>
        /// <param name="_WriteStr"></param>
        public static void WriteStrToFile(string Path, string Str)
        {
            string _Directory = Path.Substring(0, Path.LastIndexOf('/'));
            if (!Directory.Exists(_Directory))
            {
                Directory.CreateDirectory(_Directory);
            }
            FileStream fs = new FileStream(Path, FileMode.OpenOrCreate, FileAccess.Write);
            StreamWriter sw = new StreamWriter(fs, System.Text.Encoding.UTF8);
            sw.WriteLine(Str);
            sw.Flush();
            sw.Close();
            fs.Close();
        }
        public static void WriteBytesToFile(string Path, byte[] data)
        {
            string _Directory = Path.Substring(0, Path.LastIndexOf('/'));
            if (!Directory.Exists(_Directory))
            {
                Directory.CreateDirectory(_Directory);
            }
            FileStream fs = new FileStream(Path, FileMode.OpenOrCreate);
            //将byte数组写入文件中
            fs.Write(data, 0, data.Length);
            fs.Close();
        }
        /// <summary>
        /// 复制文件
        /// </summary>
        /// <param name="filePath"></param>
        /// <param name="targetPath"></param>
        public static void CopyFile(string filePath, string targetPath)
        {
            string targetDir =  Path.GetDirectoryName(targetPath);
            if (!Directory.Exists(targetDir))
            {
                Directory.CreateDirectory(targetDir);
            }
            System.IO.File.Copy(filePath, targetPath, true);
        }
        #endregion

        #region 文件夹
        /// <summary>
        /// 清除文件夹下子文件
        /// </summary>
        /// <param name="srcPath"></param>
        public static void ClearDirectory(string srcPath)
        {
            if (Directory.Exists(srcPath))
            {
                DirectoryInfo dir = new DirectoryInfo(srcPath);
                FileSystemInfo[] fileinfo = dir.GetFileSystemInfos();  //返回目录中所有文件和子目录
                foreach (FileSystemInfo i in fileinfo)
                {
                    if (i is DirectoryInfo)            //判断是否文件夹
                    {
                        DirectoryInfo subdir = new DirectoryInfo(i.FullName);
                        subdir.Delete(true);          //删除子目录和文件
                    }
                    else
                    {
                        File.Delete(i.FullName);      //删除指定文件
                    }
                }
            }
            else
            {
                Directory.CreateDirectory(srcPath);
            }
        }
        /// <summary>
        /// 清除非指定后缀的文件
        /// </summary>
        /// <param name="srcPath"></param>
        /// <param name="_Suffix"></param>
        public static void ClearDirFile(string srcPath, string[] _Suffix)
        {
            DirectoryInfo dir = new DirectoryInfo(srcPath);
            FileSystemInfo[] fileinfo = dir.GetFileSystemInfos();  //返回目录中所有文件和子目录
            foreach (FileSystemInfo i in fileinfo)
            {
                if (i is DirectoryInfo)            //判断是否文件夹
                {
                    ClearDirFile(i.FullName, _Suffix);
                }
                else
                {
                    bool IsClear = true;
                    for (int n = 0; n < _Suffix.Length; n++)
                    {
                        if (i.FullName.EndsWith(_Suffix[n]))
                        {
                            IsClear = false;
                            break;
                        }
                    }

                    if (IsClear)
                        File.Delete(i.FullName);      //删除指定文件
                }
            }
        }
        /// <summary>
        /// 复制目录文件到指定目录
        /// </summary>
        /// <param name="srcPath"></param>
        /// <param name="aimPath"></param>
        public static void CopyDirFile(string srcPath, string aimPath)
        {
            if (aimPath[aimPath.Length - 1] != Path.DirectorySeparatorChar)
            {
                aimPath += Path.DirectorySeparatorChar;
            }
            if (!Directory.Exists(aimPath))
            {
                Directory.CreateDirectory(aimPath);
            }
            string[] fileList = Directory.GetFileSystemEntries(srcPath);
            foreach (string file in fileList)
            {
                if (Directory.Exists(file))
                {
                    CopyDirFile(file, aimPath + Path.GetFileName(file));
                }
                else
                {
                    File.Copy(file, aimPath + Path.GetFileName(file), true);
                }
            }
        }
        #endregion

    }
}

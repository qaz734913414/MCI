using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using UnityEngine;

namespace MyFramework.Tools
{
    public static class ToolsConfig
    {
        /// <summary>
        /// 可编译文件
        /// </summary>
        public static string[] CanBuildFileTypes = { ".prefab", ".png", ".jpg" };

        /// <summary>
        /// 工具开发资源目录 完整路径
        /// </summary>
        public static string CompleteEditorResources
        {
            get
            {
                return Path.Combine(Application.dataPath, "MyFramework/Editor/ToolsResources");
            }
        }

        /// <summary>
        /// 工具开发资源目录 相对路径
        /// </summary>
        public static string RelativeEditorResources
        {
            get
            {
                return "Assets/MyFramework/Editor/ToolsResources";
            }
        }
    }
}

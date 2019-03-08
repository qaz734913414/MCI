using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace MyFramework.Tools
{
    public class MyFrameworkTools : EditorWindow
    {
        [MenuItem("Window/MyFrameworkTools")]
        public static void CreateView()
        {
            MyFrameworkTools newWindow = GetWindowWithRect<MyFrameworkTools>(new Rect(100, 100, 600, 400), false, "框架工具集合");
            newWindow.Init();
        }

        Dictionary<string, BaseTools> Tools;
        string CurrTools = "";
        public void Init()
        {
            Tools = new Dictionary<string, BaseTools>
            {
                //{ "样式演示工具", new StylesShowTools(this) },
                { "工程编译打包工具", new PackingTools(this) },
                { "测试工具实现界面", new TestTools(this) },
            };
        }

        #region 视图
        void OnGUI()
        {
            if (Tools == null)
            {
                Init();
            }
            EditorGUILayout.BeginHorizontal(GUILayout.ExpandWidth(true), GUILayout.ExpandHeight(true));
            LeftView();
            EditorGUILayout.BeginVertical(GUILayout.ExpandWidth(true), GUILayout.ExpandHeight(true));
            if (Tools.ContainsKey(CurrTools))
            {
                Tools[CurrTools].OnGUI();
            }
            EditorGUILayout.EndVertical();
            EditorGUILayout.EndHorizontal();
        }

        void LeftView()
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox, GUILayout.Width(80), GUILayout.ExpandHeight(true));
            foreach (var item in Tools)
            {
                if (CurrTools != item.Key)
                {
                    if (GUILayout.Button(item.Key,Styles.ButtonNoSelectStyle, GUILayout.Height(40), GUILayout.ExpandWidth(true)))
                    {
                        CurrTools = item.Key;
                    }
                }
                else
                {
                    if (GUILayout.Button(item.Key,Styles.ButtonSelectStyle, GUILayout.Height(40), GUILayout.ExpandWidth(true)))
                    {
                        CurrTools = CurrTools = item.Key;
                    }
                }
            }
            EditorGUILayout.EndVertical();
        }
        #endregion

    }

}

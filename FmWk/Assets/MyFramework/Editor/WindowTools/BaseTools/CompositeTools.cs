using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace MyFramework.Tools
{
    /// <summary>
    /// 集合界面 创建二级菜单
    /// </summary>
    public abstract class CompositeTools : BaseTools
    {
        protected Dictionary<string, BaseTools> Tools;
        protected string CurrTools = "";

        public CompositeTools(EditorWindow _MyWindow)
            :base(_MyWindow)
        {
        }

        public override void OnGUI()
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox, GUILayout.ExpandHeight(true), GUILayout.ExpandWidth(true));
            EditorGUILayout.BeginVertical(GUILayout.ExpandHeight(true), GUILayout.ExpandWidth(true));
            if (Tools.ContainsKey(CurrTools))
            {
                Tools[CurrTools].OnGUI();
            }
            EditorGUILayout.EndVertical();
            BottomView();
            EditorGUILayout.EndVertical();
        }

        protected void BottomView()
        {
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox, GUILayout.Height(40), GUILayout.ExpandWidth(true));
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
                        CurrTools = item.Key;
                    }
                }
            }
            EditorGUILayout.EndHorizontal();
        }
    }
}

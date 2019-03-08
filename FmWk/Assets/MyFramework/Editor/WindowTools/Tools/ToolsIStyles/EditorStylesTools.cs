using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace MyFramework.Tools
{
    public class EditorStylesTools : BaseTools
    {
        private List<GUIStyle> styles = null;
        private Vector2 scrollPosition = Vector2.zero;
        public EditorStylesTools(EditorWindow _MyWindow)
            :base(_MyWindow)
        {
            styles = new List<GUIStyle>();
            foreach (PropertyInfo fi in typeof(EditorStyles).GetProperties(BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic))
            {
                object o = fi.GetValue(null, null);
                if (o.GetType() == typeof(GUIStyle))
                {
                    styles.Add(o as GUIStyle);
                }
            }
        }

        public override void OnGUI()
        {
            scrollPosition = GUILayout.BeginScrollView(scrollPosition);
            for (int i = 0; i < styles.Count; i++)
            {
                GUILayout.Label("EditorStyles." + styles[i].name, styles[i]);
            }
            GUILayout.EndScrollView();
        }
    }
}

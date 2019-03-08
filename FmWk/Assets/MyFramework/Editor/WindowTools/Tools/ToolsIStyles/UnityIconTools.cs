using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace MyFramework.Tools
{
    struct BuiltinIcon : System.IEquatable<BuiltinIcon>, System.IComparable<BuiltinIcon>
    {
        public GUIContent icon;
        public GUIContent name;

        public override bool Equals(object o)
        {
            return o is BuiltinIcon && this.Equals((BuiltinIcon)o);
        }
        public override int GetHashCode()
        {
            return name.GetHashCode();
        }
        public bool Equals(BuiltinIcon o)
        {
            return this.name.text == o.name.text;
        }
        public int CompareTo(BuiltinIcon o)
        {
            return this.name.text.CompareTo(o.name.text);
        }
    }

    public class UnityIconTools : BaseTools
    {
        List<BuiltinIcon> _icons = new List<BuiltinIcon>();
        public UnityIconTools(EditorWindow _MyWindow)
            :base(_MyWindow)
        {
            Texture2D[] t = Resources.FindObjectsOfTypeAll<Texture2D>();
            foreach (Texture2D x in t)
            {
                if (x.name.Length == 0)
                    continue;
                if (x.hideFlags != HideFlags.HideAndDontSave && x.hideFlags != (HideFlags.HideInInspector | HideFlags.HideAndDontSave))
                    continue;
                if (!EditorUtility.IsPersistent(x))
                    continue;
                GUIContent gc = EditorGUIUtility.IconContent(x.name);
                if (gc == null)
                    continue;
                if (gc.image == null)
                    continue;
                _icons.Add(new BuiltinIcon()
                {
                    icon = gc,
                    name = new GUIContent(x.name)
                });
            }
            _icons.Sort();
            Resources.UnloadUnusedAssets();
            System.GC.Collect();
        }

        public Vector2 scrollPosition = Vector2.zero;
        public override void OnGUI()
        {
            scrollPosition = GUILayout.BeginScrollView(scrollPosition);
            EditorGUIUtility.labelWidth = 100;
            for (int i = 0; i < _icons.Count; ++i)
            {
                EditorGUILayout.LabelField(_icons[i].icon, _icons[i].name,GUILayout.Height(40));
                if (GUILayoutUtility.GetLastRect().Contains(Event.current.mousePosition) && Event.current.type == EventType.MouseDown && Event.current.clickCount > 1)
                {
                    EditorGUIUtility.systemCopyBuffer = _icons[i].name.text;
                    Debug.Log(_icons[i].name.text);
                }
            }
            GUILayout.EndScrollView();
        }

    }
}

using System;
using UnityEditor;
using UnityEngine;
using MyFramework;

namespace MyFramework.Tools
{
    /// <summary>
    /// 自动以属性行为
    /// </summary>
    [CustomPropertyDrawer(typeof(MFWAttributeRename))]
    public class MFWAttributeDrawere : PropertyDrawer
    {
        public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
        {
            string name = ((MFWAttributeRename)attribute).PropertyName;
            Rect LeftRect = new Rect(position.x, position.y, position.width / 2, position.height);
            Rect RightRect = new Rect(position.x+ position.width / 2, position.y, position.width / 2, position.height);
            switch (property.propertyType)
            {
                case SerializedPropertyType.Integer:
                    EditorGUI.LabelField(LeftRect, name);
                    property.intValue = EditorGUI.IntField(RightRect, property.intValue);
                    return;
                case SerializedPropertyType.Float:
                    EditorGUI.LabelField(LeftRect, name);
                    property.floatValue = EditorGUI.FloatField(RightRect, property.floatValue);
                    return;
                case SerializedPropertyType.Boolean:
                    EditorGUI.LabelField(LeftRect, name);
                    property.boolValue = EditorGUI.Toggle(RightRect, property.boolValue);
                    return;
                case SerializedPropertyType.String:
                    EditorGUI.LabelField(LeftRect,name);
                    property.stringValue = EditorGUI.TextField(RightRect, property.stringValue);
                    return;
                case SerializedPropertyType.Enum:
                    EditorGUI.LabelField(LeftRect,name);
                    property.enumValueIndex = EditorGUI.Popup(RightRect, property.enumValueIndex, property.enumNames);
                    return;
                case SerializedPropertyType.ObjectReference:
                    EditorGUI.LabelField(LeftRect, name);
                    property.objectReferenceValue = EditorGUI.ObjectField(RightRect, property.objectReferenceValue, typeof(Transform));
                    return;
                default:
                    base.OnGUI(position, property, label);
                    return;
            }
        }

        public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
        {
            return base.GetPropertyHeight(property, label);
        }
    }
}

using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace MyFramework.Tools
{
    public class ModelBaseEditor: EditorWindow
    {
        public static ModelBaseEditor newWindow;
        public static string ModelName;
        public static ModelContorlBase Model;
        public static List<ModelCompBase> ModelComps;
        public static void ShowModelView(string _ModelName,ModelContorlBase _Model,Rect Pos)
        {
            Model = _Model;
            ModelName = _ModelName;
            ModelComps = Model.GetMyComps();
            newWindow = GetWindowWithRect<ModelBaseEditor>(Pos, true, "模块详情");
        }

        public static void CloseView()
        {
            if (newWindow != null)
                newWindow.Close();
        }

        private bool showPosition;
        private Vector2 scrollPosition;
        public virtual void OnGUI()
        {
            GUILayout.BeginVertical();
            GUILayout.Label(ModelName,EditorStyles.centeredGreyMiniLabel);
            ModelCompsGUI();
            GUILayout.EndVertical();
        }

        public virtual void ModelCompsGUI()
        {
            showPosition = EditorGUILayout.Foldout(showPosition, "组件列表");
            if (showPosition)
            {
                GUILayout.BeginHorizontal(EditorStyles.helpBox);
                scrollPosition = GUILayout.BeginScrollView(scrollPosition, false, true, GUILayout.MaxHeight(400));
                for (int i = 0; i < ModelComps.Count; i++)
                {
                    GUILayout.BeginHorizontal(EditorStyles.helpBox);
                    GUILayout.BeginVertical();
                    GUILayout.Label(ModelComps[i].GetType().Name, EditorStyles.whiteLabel);
                    GUILayout.Label("状态 : " + ModelComps[i].State.ToString());
                    GUILayout.EndVertical();
                    GUILayout.EndHorizontal();
                }
                GUILayout.EndScrollView();
                GUILayout.EndHorizontal();
            }
        }
    }
}

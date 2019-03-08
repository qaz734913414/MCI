using UnityEditor;
using UnityEngine;

namespace MyFramework.Tools
{
    public class AssetCompilation : BaseTools<PackingTools>
    {
        private string CurrCatalogPath = "";
        public AssetCompilation(EditorWindow _MyWindow, PackingTools _Parent)
            :base(_MyWindow, _Parent)
        {

        }

        public override void OnGUI()
        {
            EditorGUILayout.BeginHorizontal(GUILayout.ExpandHeight(true),GUILayout.ExpandWidth(true));
            LeftView();
            RightView();
            EditorGUILayout.EndHorizontal();
        }

        private void LeftView()
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox, GUILayout.Width(60), GUILayout.ExpandHeight(true));
            EditorGUILayout.BeginVertical(GUILayout.ExpandHeight(true), GUILayout.ExpandWidth(true));
            foreach (var item in Parent.Config.ResourceCatalog)
            {
                if (CurrCatalogPath == item.Path)
                {
                    GUILayout.Label(item.Name, Styles.ResourceCatalogSelect, GUILayout.Height(25), GUILayout.Width(60));
                } else
                {
                    GUILayout.Label(item.Name, Styles.ResourceCatalogNoSelect, GUILayout.Height(25), GUILayout.Width(60));
                }
                if (GUILayoutUtility.GetLastRect().Contains(Event.current.mousePosition))
                {
                    if (Event.current.type == EventType.MouseDown)
                    {
                        CurrCatalogPath = item.Path;
                    }
                }
                GUILayout.Space(2);
            }
            EditorGUILayout.EndVertical();
            EditorGUILayout.BeginHorizontal(GUILayout.Height(20));
            if (GUILayout.Button("", Styles.ButtonAdd, GUILayout.Width(16), GUILayout.Height(16)))
            {
                string NewPath = EditorUtility.OpenFolderPanel("选择资源目录", Application.dataPath, "");
                Parent.AddNewResourceCatalog(NewPath);
            }
            EditorGUILayout.Space();
            if (GUILayout.Button("", Styles.Buttonminus, GUILayout.Width(16), GUILayout.Height(16)))
            {
                if (CurrCatalogPath != "")
                {
                    Parent.RemoveResourceCatalog(CurrCatalogPath);
                    CurrCatalogPath = "";
                }
            }
            EditorGUILayout.EndHorizontal();
            EditorGUILayout.EndVertical();
        }

        private Vector2 RightViewscrollPosition = Vector2.zero;
        private void RightView()
        {
            EditorGUILayout.BeginVertical(GUILayout.ExpandWidth(true), GUILayout.ExpandHeight(true));
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Toggle(false,"全选"))
            {
                foreach (var item in Parent.Config.ModelBuildConfig)
                {
                    item.IsSelection = true;
                }
            }
            if (GUILayout.Toggle(false,"反选"))
            {
                foreach (var item in Parent.Config.ModelBuildConfig)
                {
                    item.IsSelection = !item.IsSelection;
                }
            }
            GUILayout.Label("目標平台:",GUILayout.Width(50));
            Parent.Config.BuildPlatform = (AppPlatform)EditorGUILayout.EnumPopup(Parent.Config.BuildPlatform);
            if (GUILayout.Button("刷新", GUILayout.Width(100)))
            {
                Parent.RefreshModelConfig();
            }

            EditorGUILayout.EndHorizontal();
            RightViewscrollPosition = GUILayout.BeginScrollView(RightViewscrollPosition, EditorStyles.helpBox);
            foreach (var item in Parent.Config.ModelBuildConfig)
            {
                item.OnGUI();
            }
            GUILayout.EndScrollView();
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("资源输出目录:",GUILayout.Width(60));
            GUILayout.Label(Parent.Config.ResourceOutPath, GUILayout.Width(150));
            EditorGUILayout.Space();
            if (GUILayout.Button("选择", GUILayout.Width(80)))
            {
                string NewPath = EditorUtility.OpenFolderPanel("资源输出目录", Application.dataPath, "");
                Parent.Config.ResourceOutPath = NewPath;
            }
            if (GUILayout.Button("编译", GUILayout.Width(80)))
            {
                EditorApplication.delayCall += Parent.BuildResourceModel;
            }
            EditorGUILayout.EndHorizontal();
            EditorGUILayout.EndVertical();
        }




    }
}

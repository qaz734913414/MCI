using UnityEditor;
using UnityEngine;

namespace MyFramework.Tools
{
    public class AssetBundleTest : BaseTools
    {
        private Vector2 scrollPosition = Vector2.zero;
        public AssetBundleTest(EditorWindow _MyWindow)
            : base(_MyWindow)
        {
            
        }

        public override void OnGUI()
        {
            scrollPosition = GUILayout.BeginScrollView(scrollPosition);
            if (GUILayout.Button("TestAssetBundle", Styles.ButtonSelectStyle, GUILayout.Height(40), GUILayout.ExpandWidth(true)))
            {
                LoggerHelper.Debug("测试代码");
                TestAssetBundle();
            }
            GUILayout.EndScrollView();
        }

        private void TestAssetBundle() {
            string ResourceOutPath = "D:/Project/U3DProject/U3DFmWk/FmWk/Assets/StreamingAssets";
            AssetBundleBuild[] builds = new AssetBundleBuild[1];
            builds[0] = new AssetBundleBuild()
            {
                assetBundleName = "liwei1dao.1dao",
                assetNames = new string[] { "Assets/MaJiangModule/Asset/3DMJ/mj.png" },
            };
            AssetBundleManifest BundleInfo = BuildPipeline.BuildAssetBundles(ResourceOutPath, builds, BuildAssetBundleOptions.None, BuildTarget.StandaloneWindows64);
            AssetDatabase.Refresh();
        }
    }
}

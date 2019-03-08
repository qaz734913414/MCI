using System.Collections.Generic;
using UnityEditor;

namespace MyFramework.Tools
{
    public class TestTools : CompositeTools
    {
        public TestTools(EditorWindow _MyWindow)
     : base(_MyWindow)
        {
            Tools = new Dictionary<string, BaseTools>
            {
                { "AssetBundleTest",new AssetBundleTest(_MyWindow)}
            };
        }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;

namespace MyFramework.Tools
{
    public class StylesShowTools : CompositeTools
    {
        public StylesShowTools(EditorWindow _MyWindow)
            :base(_MyWindow)
        {
            Tools = new Dictionary<string, BaseTools>
            {
                { "Unity样式演示", new EditorStylesTools(_MyWindow)},
                { "Unity图标演示", new UnityIconTools(_MyWindow) }
            };
        }
    }
}

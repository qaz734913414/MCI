using UnityEngine;

namespace MyFramework
{
    public class MFWAttributeRename : PropertyAttribute
    {
        public string PropertyName;
        public MFWAttributeRename(string name)
        {
            PropertyName = name;
        }
    }

}

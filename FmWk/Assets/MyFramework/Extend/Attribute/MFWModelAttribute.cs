using System;

namespace MyFramework
{
    [AttributeUsage(AttributeTargets.Field)]
    public class MFWModel_SerializeAttribute : Attribute
    {
        public bool IsWrite;
        public MFWModel_SerializeAttribute()
        {
            IsWrite = false;
        }
        public MFWModel_SerializeAttribute(bool _IsWrite)
        {
            IsWrite = _IsWrite;
        }
    }

    [AttributeUsage(AttributeTargets.Field)]
    public class MFWModel_SerializeNameAttribute : MFWModel_SerializeAttribute
    {
        public string Name;
        public MFWModel_SerializeNameAttribute(string _Name)
            :base()
        {
            Name = _Name;
        }
        public MFWModel_SerializeNameAttribute(string _Name,bool _IsWrite)
            : base(_IsWrite)
        {
            Name = _Name;
        }
    }
}

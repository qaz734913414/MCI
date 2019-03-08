using LuaInterface;
using System.Reflection;

namespace MyFramework
{
    /// <summary>
    /// Lua模块控制器
    /// </summary>
    public class LuaModelControlBase : ManagerContorBase
    {
        public LuaModelControlBase(string _ModelName)
            : base()
        {
            ModelName = _ModelName;
            LuaManagerModel.Instance.AddLuaModel(ModelName);
            LuaManagerModel.Instance.DoFile(ModelName, "Main");
            LuaFunction func = LuaManagerModel.Instance.GetFunction(ModelName + ".New");
            if (func != null)
            {
                func.BeginPCall();
                func.PushObject(this);
                func.PCall();
                func.EndPCall();
            }
        }
        public override void Load<Model>(ModelLoadBackCall<Model> _LoadBackCall, params object[] _Agr)
        {
            base.Load<Model>(_LoadBackCall,_Agr);
            LuaFunction func = LuaManagerModel.Instance.GetFunction(ModelName + ".Load");
            if (func != null)
            {
                func.BeginPCall();
                func.PushArgs(_Agr);
                func.PCall();
                func.EndPCall();
            }
        }

        /// <summary>
        /// 获取cs层组件加载情况
        /// </summary>
        /// <returns></returns>
        private bool GetLoadEnd()
        {
            if (State > ModelBaseState.LoadEnd) 
                return false;
            for (int i = 0; i < MyComps.Count; i++)
            {
                if (MyComps[i].State != ModelCompBaseState.LoadEnd)
                {
                    return false;
                }
            }
            if (State <= ModelBaseState.LoadEnd)
            {
                State = ModelBaseState.LoadEnd;
                return true;
            }
            else
            {
                return false;
            }
        }

        public override bool LoadEnd()
        {
            //LoggerHelper.Debug("Cs LoadEnd   Name =" + ModelName+ "  State ="+ State.ToString());
            LuaFunction func = LuaManagerModel.Instance.GetFunction(ModelName + ".LoadEnd");
            func.BeginPCall();
            func.PCall();
            bool IsLuaLoadEnd = (bool)func.CheckBoolean();
            func.EndPCall();
            //LoggerHelper.Debug("Cs -----------LoadEnd  IsLuaLoadEnd = " + IsLuaLoadEnd+ "  *************  IsCsLoadEnd" + GetLoadEnd());
            if (IsLuaLoadEnd && GetLoadEnd())
            {
                if (LoadBackCall != null)
                {
                    LoadBackCall(this);
                    LoadBackCall = null;
                }
                return true;
            }
            else
            {
                return false;
            }
        }

        public override void Start(params object[] _Agr)
        {
            LoggerHelper.Debug("Lua Start:" + ModelName);
            base.Start(_Agr);
            LuaFunction func = LuaManagerModel.Instance.GetFunction(ModelName + ".Start");
            if (func != null)
            {
                func.BeginPCall();
                func.PushArgs(_Agr);
                func.PCall();
                func.EndPCall();
            }

        }
        public override void Close()
        {
            LuaFunction func = LuaManagerModel.Instance.GetFunction(ModelName + ".Close");
            if (func != null)
            {
                func.BeginPCall();
                func.PCall();
                func.EndPCall();
            }
            LuaManagerModel.Instance.RemoveLuaModel(ModelName);
            base.Close();
        }

        public virtual ModelCompBase AddComp(string nameSpace, string CPName, params object[] _Agr)
        {
            ModelCompBase Comp = Assembly.GetExecutingAssembly().CreateInstance(nameSpace + "." + CPName, true, System.Reflection.BindingFlags.Default, null, null, null, null) as ModelCompBase;
            MyComps.Add(Comp);
            if (State > ModelBaseState.Close)
                Comp.Load(this, _Agr);
            if (State == ModelBaseState.Start)
                Comp.Start(this, _Agr);
            return Comp;
        }

        public void LoadResourceComp()
        {
            ResourceComp = AddComp<Model_ResourceComp>();
        }
    }

    public class LuaUpdataModelControl : LuaModelControlBase, IUpdataMode
    {
        LuaFunction LuaUpdate;
        public LuaUpdataModelControl(string _ModelName)
            :base(_ModelName)
        {
            LuaUpdate = LuaManagerModel.Instance.GetFunction(ModelName + ".Update");
        }

        public void Update(float time)
        {
            if (LuaUpdate != null)
            {
                LuaUpdate.BeginPCall();
                LuaUpdate.Push(time);
                LuaUpdate.PCall();
                LuaUpdate.EndPCall();
            }
        }
    }

    public class LuaFixedUpdateModelControl : LuaModelControlBase, IFixedUpdateMode
    {
        LuaFunction LuaFixedUpdate;
        public LuaFixedUpdateModelControl(string _ModelName)
            : base(_ModelName)
        {
            LuaFixedUpdate = LuaManagerModel.Instance.GetFunction(ModelName + ".FixedUpdate");
        }

        public void FixedUpdate()
        {
            if (LuaFixedUpdate != null)
            {
                LuaFixedUpdate.BeginPCall();
                LuaFixedUpdate.PCall();
                LuaFixedUpdate.EndPCall();
            }
        }
    }

    public class LuaModelControlBase<C> : LuaModelControlBase
    {
        public LuaModelControlBase()
            : base(typeof(C).Name)
        {

        }
        public LuaModelControlBase(string _ModelName)
            : base(_ModelName)
        {

        }
    }
}

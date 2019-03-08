using UnityEngine;

namespace MyFramework
{
    public abstract class Singleton<T> where T : Singleton<T>, new()
    {
        private static T instance;
        public static T Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new T();
                }
                return instance;
            }
        }
    }

    /// <summary>
    /// 继承MonoBehaviour 的 单例对象 直接创建GameObjec 添加管理器类
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public abstract class ManagerMonoSingleton<T> : MonoBehaviour where T : ManagerMonoSingleton<T>
    {
        private static T _instance = null;
        public static T Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = FindObjectOfType(typeof(T)) as T;
                    if (_instance == null)
                    {
                        GameObject obj = new GameObject(typeof(T).Name, typeof(T));
                        _instance = obj.GetComponent<T>() as T;
                        _instance.Init();
                    }
                }
                return _instance;
            }
        }

        /// <summary>
        /// 是否跳转场景不删除
        /// </summary>
        protected bool IsDontDestroyOnLoad = false;

        protected virtual void Init()
        {

        }
        protected virtual void Awake()
        {
            if (IsDontDestroyOnLoad)
                DontDestroyOnLoad(gameObject);
        }
    }

    /// <summary>
    /// Prefab 单例基类
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public abstract class PrefabSingleton<T> : MonoBehaviour where T : PrefabSingleton<T>
    {
        private static T instance;
        public static T Instance
        {
            get
            {
                return instance;
            }
        }

        /// <summary>
        /// 是否跳转场景不删除
        /// </summary>
        protected bool IsDontDestroyOnLoad = false;

        protected virtual void Awake()
        {
            if (IsDontDestroyOnLoad)
                DontDestroyOnLoad(gameObject);
            instance = gameObject.GetComponent<T>();
            Init();
        }

        protected virtual void Init()
        {

        }
    }
}

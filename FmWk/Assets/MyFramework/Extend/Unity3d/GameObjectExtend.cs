using System;
using UnityEngine;

public static class GameObjectExtend  {

    /// <summary>
    /// 查找添加组件
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="go"></param>
    /// <returns></returns>
    static public T AddMissingComponent<T>(this GameObject go) where T : Component
    {
        T comp = go.GetComponent<T>();
        if (comp == null)
        {
            comp = go.AddComponent<T>();
        }
        return comp;
    }

    /// <summary>
    /// 创建游戏对象
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="_Object"></param>
    /// <param name="Parent"></param>
    /// <returns></returns>
    public static GameObject CreateToParnt(this UnityEngine.Object _Object, GameObject Parent)
    {
        GameObject obj = GameObject.Instantiate(_Object) as GameObject;
        if (obj != null)
        {
            obj.SetParent(Parent.transform);
        }
        return obj;
    }
    /// <summary>
    /// 创建子对象
    /// </summary>
    /// <param name="Parent"></param>
    public static GameObject CreateChild(this GameObject Parent, string name, params Type[] components)
    {
        GameObject child = new GameObject(name, components);
        child.SetParent(Parent.transform);
        return child;
    }

    /// <summary>
    /// 設置父物体对象
    /// </summary>
    /// <param name="Target"></param>
    /// <param name="Parent"></param>
    public static void SetParent(this GameObject Target, Transform Parent)
    {
        Target.transform.parent = Parent;
        Target.transform.localPosition = Vector3.zero;
        Target.transform.localScale = Vector3.one;
        Target.transform.localRotation = Quaternion.identity;
    }

    /// <summary>
    /// 设置对象以及子对象层
    /// </summary>
    /// <param name="Target"></param>
    /// <param name="layer"></param>
    public static void SetLayer(this GameObject Target, LayerMask layer)
    {
        Target.layer = layer;
        for (int i = 0; i < Target.transform.childCount; i++)
        {
            Target.transform.GetChild(i).gameObject.SetLayer(layer);
        }
    }

    /// <summary>
    /// 设置对象trans
    /// </summary>
    /// <param name="Target"></param>
    /// <param name="Parent"></param>
    public static void SetTrans(this GameObject Target, Transform Parent)
    {
        Target.transform.position = Parent.position;
        Target.transform.localScale = Vector3.one;
        Target.transform.rotation = Parent.rotation;
    }



    /// <summary>
    /// 找到子节点的组件
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="Target"></param>
    /// <param name="Childpath"></param>
    /// <returns></returns>
    public static T OnSubmit<T>(this GameObject Target, string Childpath) where T : Component
    {
        Transform obj = Target.transform.Find(Childpath);
        if (obj != null)
        {
            return obj.GetComponent<T>();
        }
        return null;
    }
}

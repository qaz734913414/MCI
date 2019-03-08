using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace MyFramework
{
    /// <summary>
    /// 列表数据
    /// </summary>
    public interface ListDataTable
    {

    }
    public interface ConfigData
    {

    }

    public class ConfigDataBase : ScriptableObject, ConfigData
    {

    }

    [SerializeField]
    public class ConfigDataBase<K> : ConfigData
    {
        public K Id;
    }

    public class ConfigTableDataBase<D> : ScriptableObject,ListDataTable where D : ConfigData
    {
        public List<D> Datas = new List<D>();
        public void AddData(D data)
        {
            Datas.Add(data);
        }
    }

    public class ConfigTableDataBase<K, D> : ConfigTableDataBase<D> where D: ConfigDataBase<K>
    {
        protected Dictionary<K, D> _data = null;

        /// <summary>
        /// 获取数据
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        public D GetData(K key)
        {
            if (_data == null)
            {
                _data = new Dictionary<K, D>();
                for (int i = 0; i < Datas.Count; i++)
                {
                    if (!_data.ContainsKey(Datas[i].Id))
                    {
                        _data[Datas[i].Id] = Datas[i];
                    }
                    else
                    {
                        LoggerHelper.Error(this.name + ": 有重复数据存在 " + Datas[i].Id.ToString());
                    }
                }
            }

            if (_data.ContainsKey(key))
            {
                return _data[key];
            }
            else
            {
                LoggerHelper.Error(this.name + ": 没有找到数据 " + key.ToString());
                return default(D);
            }
        }
    }
}


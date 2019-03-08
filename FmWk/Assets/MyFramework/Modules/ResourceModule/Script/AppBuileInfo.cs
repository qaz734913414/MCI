using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using UnityEngine;

namespace MyFramework
{
    public enum AssetCheckMode               //资源校验方式
    {
        AppStartCheck,                       //APP启动校验
        ModelStartCheck,                     //模块启动校验
        UserCheck,                           //使用时校验
    }

    [Serializable]
    [JsonObject(MemberSerialization.OptOut)]
    public class ResBuileInfo
    {
        public string Id;                  //模块名
        public string Model;               //所属模块
        public float Size;                 //文件大小 单位kb
        public string Md5;                 //文件md5值
        public AssetCheckMode CheckModel;  //资源校验模式
        public bool IsNeedUpdata = false;  //是否更新完毕
        public string[] Dependencies;      //资源的依赖关系
        [JsonIgnore]
        public List<string> Assets;        //Buile 序列化忽略的值
    }

    [JsonObject(MemberSerialization.OptIn)]
    public class AppBuileInfo : ScriptableObject
    {
        [JsonProperty]
        public Dictionary<string,ResBuileInfo> AppResInfo;

        public AppBuileInfo()
        {
            AppResInfo = new Dictionary<string, ResBuileInfo>();
        }
    }
}

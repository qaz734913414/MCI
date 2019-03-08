using System;
using System.Runtime.InteropServices;

public static class DataChangeTools
{
    /// <summary>
    /// 结构体转byte数组
    /// </summary>
    /// <param name="structure"></param>
    /// <returns></returns>
    public static Byte[] StructToBytes(object structure)
    {
        //得到结构体的大小
        int size = Marshal.SizeOf(structure);
        //创建byte数组
        byte[] bytes = new byte[size];
        //分配结构体大小的内存空间
        IntPtr structPtr = Marshal.AllocHGlobal(size);
        //将结构体拷到分配好的内存空间
        Marshal.StructureToPtr(structure, structPtr, false);
        //从内存空间拷到byte数组
        Marshal.Copy(structPtr, bytes, 0, size);
        //释放内存空间
        Marshal.FreeHGlobal(structPtr);
        //返回byte数组
        return bytes;
    }

    /// <summary>
    /// 数组转结构体
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="bytes"></param>
    /// <param name="type"></param>
    /// <returns></returns>
    public static T ByteaToStruct<T>(byte[] bytes) where T : struct
    {
        T type = new T();
        int size = Marshal.SizeOf(type);
        if (size > bytes.Length)
        {
            throw new ArgumentOutOfRangeException("byte转结构体异常 Struct =" + typeof(T).Name + "  Data = " + bytes.Length);
        }
        IntPtr structPtr = Marshal.AllocHGlobal(size);
        Marshal.Copy(bytes, 0, structPtr, size);
        object obj = Marshal.PtrToStructure(structPtr, type.GetType());
        Marshal.FreeHGlobal(structPtr);
        return (T)obj;
    }
}

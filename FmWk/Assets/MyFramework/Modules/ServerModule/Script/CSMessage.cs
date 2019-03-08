using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

namespace MyFramework
{
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct CSMessageHead
    {
        public UInt16 ComId;
        public UInt16 MsgId;
        public UInt32 MsgLength;

        public CSMessageHead(UInt16 _ComId, UInt16 _MsgId,UInt32 _Length)
        {
            ComId = _ComId;
            MsgId = _MsgId;
            MsgLength = _Length;
        }

        public CSMessageHead(byte[] _buffer)
        {
            ComId = 0;
            MsgId = 0;
            MsgLength = 0;
            Deserialize(_buffer);
        }

        public byte[] Serialize(){
            byte[] _msgleng = BitConverter.GetBytes(MsgLength).Reverse().ToArray();
            byte[] _comid = BitConverter.GetBytes(ComId).Reverse().ToArray();
            byte[] _msgid = BitConverter.GetBytes(MsgId).Reverse().ToArray();


            byte[] resArr = new byte[8];
            _msgleng.CopyTo(resArr, 0);
            _comid.CopyTo(resArr, 4);
            _msgid.CopyTo(resArr, 6);
            return resArr;
        }

        public void Deserialize(byte[] _buffer) {
            try
            {
                if (_buffer.Length < 8)
                {
                    throw new Exception("消息头协议异常 包头大小不对 _buffer Leng = " + _buffer.Length);
                }
                else {
                    MsgLength = BitConverter.ToUInt32(_buffer.Skip(0).Take(4).Reverse().ToArray(), 0);
                    ComId = BitConverter.ToUInt16(_buffer.Skip(4).Take(6).Reverse().ToArray(), 0);
                    MsgId = BitConverter.ToUInt16(_buffer.Skip(6).Take(8).Reverse().ToArray(), 0);
                }
            }
            catch (Exception ex)
            {
                throw new Exception("消息头协议异常" + ex.ToString());
            }
        }

    }
    public class CSMessage
    {
        public CSMessageHead Head;
        public byte[] Msg;

        public int ReadMsg(byte[] msg)
        {
            byte[] headdata = msg.Skip(0).Take(8).ToArray();
            //Head = DataChangeTools.ByteaToStruct<CSMessageHead>(headdata);                    //结构体序列化 展示弃用
            Head = new CSMessageHead(headdata);
            if (msg.Length >= Head.MsgLength + 8)
            {
                Msg = msg.Skip(8).Take((int)Head.MsgLength).ToArray();
                return (int)Head.MsgLength + 8;
            }
            else
            {
                throw new ArgumentOutOfRangeException("CSMessage读取异常 " + Head.ComId + "  Data = " + Head.MsgId+ " Data.Length ="+ msg.Length);
            }
        }

        public void WriteMsg(UInt16 _ComId, UInt16 _MsgId, byte[] _Msg)
        {
            Msg = _Msg;
            Head = new CSMessageHead(_ComId, _MsgId, (UInt32)Msg.Length);
        }

        public byte[] ToBytes()
        {
            //byte[] msg = DataChangeTools.StructToBytes(Head).Concat(Msg).ToArray();               //结构体序列化 展示弃用
            byte[] msg = Head.Serialize().Concat(Msg).ToArray();
            return msg;
        }
    }
}

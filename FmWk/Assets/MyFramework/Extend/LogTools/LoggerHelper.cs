﻿using UnityEngine;
using System;
using System.IO;
using System.Text;
using System.Diagnostics;

namespace MyFramework
{
    /// <summary>
    /// 日志等级声明。
    /// </summary>
    [Flags]
    public enum LogLevel
    {
        /// <summary>
        /// 缺省
        /// </summary>
        NONE = 0,
        /// <summary>
        /// 调试
        /// </summary>
        DEBUG = 1,
        /// <summary>
        /// 信息
        /// </summary>
        INFO = 2,
        /// <summary>
        /// 警告
        /// </summary>
        WARNING = 4,
        /// <summary>
        /// 错误
        /// </summary>
        ERROR = 8,
        /// <summary>
        /// 异常
        /// </summary>
        EXCEPT = 16,
        /// <summary>
        /// 关键错误
        /// </summary>
        CRITICAL = 32,
    }
    /// <summary>
    /// 日志管理工具
    /// </summary>
    public static class LoggerHelper
    {
        /// <summary>
        /// 当前日志记录等级。
        /// </summary>
        public static LogLevel CurrentLogLevels = LogLevel.DEBUG | LogLevel.INFO | LogLevel.WARNING | LogLevel.ERROR | LogLevel.CRITICAL | LogLevel.EXCEPT;
        /// <summary>
        /// 显示堆栈
        /// </summary>
        private const Boolean SHOW_STACK = true;
        /// <summary>
        /// 日志过滤字符
        /// </summary>
        public static string DebugFilterStr = string.Empty;
        /// <summary>
        /// 写日志
        /// </summary>
        private static LogWriter m_logWriter;
        static ulong index = 0;

        static LoggerHelper()
        {
            m_logWriter = new LogWriter();
            Application.logMessageReceived += new Application.LogCallback(ProcessExceptionReport);
        }

        /// <summary>
        /// 日志分发
        /// </summary>
        /// <param name="message"></param>
        /// <param name="stackTrace"></param>
        /// <param name="type"></param>
        private static void ProcessExceptionReport(string message, string stackTrace, LogType type)
        {
            var logLevel = LogLevel.DEBUG;
            switch (type)
            {
                case LogType.Assert:
                    logLevel = LogLevel.DEBUG;
                    break;
                case LogType.Error:
                    logLevel = LogLevel.ERROR;
                    break;
                case LogType.Exception:
                    logLevel = LogLevel.EXCEPT;
                    break;
                case LogType.Log:
                    logLevel = LogLevel.DEBUG;
                    break;
                case LogType.Warning:
                    logLevel = LogLevel.WARNING;
                    break;
                default:
                    break;
            }

            if (logLevel == (CurrentLogLevels & logLevel))
                Log(string.Concat(" [SYS_", logLevel, "]: ", message, '\n', stackTrace), logLevel, false);
        }

        #region 堆栈信息
        /// <summary>
        /// 获取调用栈信息。
        /// </summary>
        /// <returns>调用栈信息</returns>
        private static String GetStackInfo()
        {
            StackTrace st = new StackTrace();
            StackFrame sf = st.GetFrame(2);//[0]为本身的方法 [1]为调用方法
            var method = sf.GetMethod();
            return String.Format("{0}.{1}(): ", method.ReflectedType.Name, method.Name);
        }

        /// <summary>
        /// 获取堆栈信息。
        /// </summary>
        /// <returns></returns>
        private static String GetStacksInfo()
        {
            StringBuilder sb = new StringBuilder();
            StackTrace st = new StackTrace();
            var sf = st.GetFrames();
            for (int i = 2; i < sf.Length; i++)
            {
                sb.AppendLine(sf[i].ToString());
            }

            return sb.ToString();
        }
        #endregion

        #region 对外入口
        /// <summary>
        /// 调试日志。
        /// </summary>
        /// <param name="message">日志内容</param>
        /// <param name="isShowStack">是否显示调用栈信息</param>
        public static void Debug(object message, Boolean isShowStack = SHOW_STACK, int user = 0)
        {
            //if (user != 11)
            //    return;
            if (DebugFilterStr != "") return;

            if (LogLevel.DEBUG == (CurrentLogLevels & LogLevel.DEBUG))
                Log(string.Concat(" [DEBUG]: ", isShowStack ? GetStackInfo() : "", message, " Index = ", index++), LogLevel.DEBUG);
        }
        /// <summary>
        /// 扩展debug
        /// </summary>
        /// <param name="message"></param>
        /// <param name="filter">只输出与在DebugMsg->filter里面设置的filter一样的debug</param>
        public static void Debug(string filter, object message, Boolean isShowStack = SHOW_STACK)
        {

            if (DebugFilterStr != "" && DebugFilterStr != filter) return;
            if (LogLevel.DEBUG == (CurrentLogLevels & LogLevel.DEBUG))
            {
                Log(string.Concat(" [DEBUG]: ", isShowStack ? GetStackInfo() : "", message), LogLevel.DEBUG);
            }
        }

        /// <summary>
        /// 信息日志。
        /// </summary>
        /// <param name="message">日志内容</param>
        public static void Info(object message, Boolean isShowStack = SHOW_STACK)
        {
            if (LogLevel.INFO == (CurrentLogLevels & LogLevel.INFO))
                Log(string.Concat(" [INFO]: ", isShowStack ? GetStackInfo() : "", message), LogLevel.INFO);
        }

        /// <summary>
        /// 警告日志。
        /// </summary>
        /// <param name="message">日志内容</param>
        public static void Warning(object message, Boolean isShowStack = SHOW_STACK)
        {
            if (LogLevel.WARNING == (CurrentLogLevels & LogLevel.WARNING))
                Log(string.Concat(" [WARNING]: ", isShowStack ? GetStackInfo() : "", message), LogLevel.WARNING);
        }

        /// <summary>
        /// 异常日志。
        /// </summary>
        /// <param name="message">日志内容</param>
        public static void Error(object message, Boolean isShowStack = SHOW_STACK)
        {
            if (LogLevel.ERROR == (CurrentLogLevels & LogLevel.ERROR))
                Log(string.Concat(" [ERROR]: ", message, '\n', isShowStack ? GetStacksInfo() : ""), LogLevel.ERROR);
        }

        /// <summary>
        /// 关键日志。
        /// </summary>
        /// <param name="message">日志内容</param>
        public static void Critical(object message, Boolean isShowStack = SHOW_STACK)
        {
            if (LogLevel.CRITICAL == (CurrentLogLevels & LogLevel.CRITICAL))
                Log(string.Concat(" [CRITICAL]: ", message, '\n', isShowStack ? GetStacksInfo() : ""), LogLevel.CRITICAL);
        }

        /// <summary>
        /// 异常日志。
        /// </summary>
        /// <param name="ex">异常实例。</param>
        public static void Except(Exception ex, object message = null)
        {
            if (LogLevel.EXCEPT == (CurrentLogLevels & LogLevel.EXCEPT))
            {
                Exception innerException = ex;
                while (innerException.InnerException != null)
                {
                    innerException = innerException.InnerException;
                }
                Log(string.Concat(" [EXCEPT]: ", message == null ? "" : message + "\n", ex.Message, innerException.StackTrace), LogLevel.CRITICAL);
            }
        }

        #endregion

        /// <summary>
        /// 写日志。
        /// </summary>
        /// <param name="message">日志内容</param>
        private static void Log(string message, LogLevel level, bool writeEditorLog = true)
        {
            var msg = string.Concat(DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss,fff"), message);
            m_logWriter.WriteLog(msg, level, writeEditorLog);
            //Debugger.Log(0, "TestRPC", message);
        }
    }
    /// <summary>
    /// 日志写入文件管理类。
    /// </summary>
    public class LogWriter
    {
        private string m_logPath = Application.persistentDataPath + "/log/";
        private string m_logFileName = "log_{0}.txt";
        private string m_logFilePath;
        private FileStream m_fs;
        private StreamWriter m_sw;
        private Action<String, LogLevel, bool> m_logWriter;
        private readonly static object m_locker = new object();

        /// <summary>
        /// 默认构造函数。
        /// </summary>
        public LogWriter()
        {
            if (!Directory.Exists(m_logPath))
                Directory.CreateDirectory(m_logPath);
            m_logFilePath = String.Concat(m_logPath, String.Format(m_logFileName, DateTime.Today.ToString("yyyyMMdd")));
            try
            {
                m_logWriter = Write;
                m_fs = new FileStream(m_logFilePath, FileMode.Append, FileAccess.Write, FileShare.ReadWrite);
                m_sw = new StreamWriter(m_fs);
            }
            catch (Exception ex)
            {
                UnityEngine.Debug.LogError(ex.Message);
            }
        }

        /// <summary>
        /// 释放资源。
        /// </summary>
        public void Release()
        {
            lock (m_locker)
            {
                if (m_sw != null)
                {
                    m_sw.Close();
                    m_sw.Dispose();
                }
                if (m_fs != null)
                {
                    m_fs.Close();
                    m_fs.Dispose();
                }
            }
        }

        /// <summary>
        /// 写日志。
        /// </summary>
        /// <param name="msg">日志内容</param>
        public void WriteLog(string msg, LogLevel level, bool writeEditorLog)
        {
#if UNITY_IPHONE
		m_logWriter(msg, level, writeEditorLog);
#else
            m_logWriter.BeginInvoke(msg, level, writeEditorLog, null, null);
#endif
        }

        private void Write(string msg, LogLevel level, bool writeEditorLog)
        {
            lock (m_locker)
                try
                {
                    if (writeEditorLog)
                    {
                        switch (level)
                        {
                            case LogLevel.DEBUG:
                            case LogLevel.INFO:
                                UnityEngine.Debug.Log(msg);
                                break;
                            case LogLevel.WARNING:
                                UnityEngine.Debug.LogWarning(msg);
                                break;
                            case LogLevel.ERROR:
                            case LogLevel.EXCEPT:
                            case LogLevel.CRITICAL:
                                UnityEngine.Debug.LogError(msg);
                                break;
                            default:
                                break;
                        }
                    }
                    if (m_sw != null)
                    {
                        m_sw.WriteLine(msg);
                        m_sw.Flush();
                    }
                }
                catch (Exception ex)
                {
                    UnityEngine.Debug.LogError(ex.Message);
                }
        }
    }
}

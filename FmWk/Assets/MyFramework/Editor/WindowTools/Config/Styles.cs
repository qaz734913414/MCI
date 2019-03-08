using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace MyFramework.Tools
{
    public static class Styles
    {
        private static GUIStyle mButtonNoSelectStyle;
        public static GUIStyle ButtonNoSelectStyle
        {
            get
            {
                if (mButtonNoSelectStyle == null)
                {
                    mButtonNoSelectStyle = new GUIStyle
                    {
                        normal = new GUIStyleState()
                        {
                            background = AssetDatabase.LoadAssetAtPath<Texture2D>(Path.Combine(ToolsConfig.RelativeEditorResources,"Button_Main_NoHover.png")),
                            textColor = Color.white
                        },
                        hover = new GUIStyleState()
                        {
                            background = AssetDatabase.LoadAssetAtPath<Texture2D>(Path.Combine(ToolsConfig.RelativeEditorResources, "Button_Main_Hover.png")),
                            textColor = Color.white
                        },
                        border = new RectOffset(0,0,0,0),
                        alignment = TextAnchor.MiddleCenter
                    };
                }
                return mButtonNoSelectStyle;
            }
        }

        private static GUIStyle mButtonSelectStyle;
        public static GUIStyle ButtonSelectStyle
        {
            get
            {
                if (mButtonSelectStyle == null)
                {
                    mButtonSelectStyle = new GUIStyle
                    {
                        normal = new GUIStyleState()
                        {
                            background = AssetDatabase.LoadAssetAtPath<Texture2D>(Path.Combine(ToolsConfig.RelativeEditorResources, "Button_Main_Hover.png")),
                            textColor = Color.white
                        },
                        border = new RectOffset(0, 0, 0, 0),
                        alignment = TextAnchor.MiddleCenter
                    };
                }
                return mButtonSelectStyle;
            }
        }

        private static GUIStyle mButtonAdd;
        public static GUIStyle ButtonAdd
        {
            get
            {
                if (mButtonAdd == null)
                {
                    mButtonAdd = new GUIStyle
                    {
                        normal = new GUIStyleState()
                        {
                            background = AssetDatabase.LoadAssetAtPath<Texture2D>(Path.Combine(ToolsConfig.RelativeEditorResources, "button_add.png")),
                        },
                    };
                }
                return mButtonAdd;
            }
        }

        private static GUIStyle mButtonminus;
        public static GUIStyle Buttonminus
        {
            get
            {
                if (mButtonminus == null)
                {
                    mButtonminus = new GUIStyle
                    {
                        normal = new GUIStyleState()
                        {
                            background = AssetDatabase.LoadAssetAtPath<Texture2D>(Path.Combine(ToolsConfig.RelativeEditorResources, "button_minus.png")),
                        },
                    };
                }
                return mButtonminus;
            }
        }

        private static GUIStyle mResourceCatalogNoSelect;
        public static GUIStyle ResourceCatalogNoSelect
        {
            get
            {
                if (mResourceCatalogNoSelect == null)
                {
                    mResourceCatalogNoSelect = new GUIStyle
                    {
                        normal = new GUIStyleState()
                        {
                            textColor = Color.black,
                            background = AssetDatabase.LoadAssetAtPath<Texture2D>(Path.Combine(ToolsConfig.RelativeEditorResources, "HUD_ActionBar_Slot_Empty.png")),
                        },
                        alignment = TextAnchor.MiddleLeft,
                        clipping = TextClipping.Clip,
                    };
                }
                return mResourceCatalogNoSelect;
            }
        }

        private static GUIStyle mResourceCatalogSelect;
        public static GUIStyle ResourceCatalogSelect
        {
            get
            {
                if (mResourceCatalogSelect == null)
                {
                    mResourceCatalogSelect = new GUIStyle
                    {
                        normal = new GUIStyleState()
                        {
                            textColor = Color.green,
                            background = AssetDatabase.LoadAssetAtPath<Texture2D>(Path.Combine(ToolsConfig.RelativeEditorResources, "HUD_ActionBar_Slot_Empty.png")),
                        },
                        alignment = TextAnchor.MiddleLeft,
                        clipping = TextClipping.Clip,
                    };
                }
                return mResourceCatalogSelect;
            }
        }
    }
}

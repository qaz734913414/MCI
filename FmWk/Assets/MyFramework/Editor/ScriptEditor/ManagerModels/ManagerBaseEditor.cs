using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Collections;
using System;
using System.Reflection;

namespace MyFramework.Tools
{
    [CustomEditor(typeof(ManagerBase))]
    public class ManagerBaseEditor : Editor
    {
        ManagerBase obj;
        Dictionary<string, ModelContorlBase> Models;
        List<string> ModelNames;
        
        bool IsInit = false;

        bool showPosition = true;
        public Vector2 scrollPosition = Vector2.zero;
        Dictionary<string, bool> ModelToggle;
        Dictionary<string, bool> ModelDetailsToggle;
        Dictionary<string, bool> ModelCompToggle;
        Dictionary<string, Vector2> ModelDetailsPos;

        public void initMe()
        {
            obj = ((ManagerBase)target);
            Models = obj.Models;
            ModelNames = new List<string>(Models.Keys);
            ModelToggle = new Dictionary<string, bool>();
            ModelDetailsToggle = new Dictionary<string, bool>();
            ModelCompToggle = new Dictionary<string, bool>();
            ModelDetailsPos = new Dictionary<string, Vector2>();
            for (int i = 0; i < ModelNames.Count; i++)
            {
                ModelToggle[ModelNames[i]] = false;
                ModelDetailsToggle[ModelNames[i]] = false;
                ModelCompToggle[ModelNames[i]] = false;
                ModelDetailsPos[ModelNames[i]] = Vector2.zero;
            }
            IsInit = true;
        }

        Rect ItemRect = new Rect(1,1.5f,100,44);
        public override void OnInspectorGUI()
        {
            if(!IsInit) initMe();
            EditorGUI.indentLevel = 0;
            showPosition = EditorGUILayout.Foldout(showPosition, "模块列表");
            GUILayout.BeginHorizontal(EditorStyles.helpBox);
            if (showPosition)
            {
                scrollPosition = GUILayout.BeginScrollView(scrollPosition,false,true,GUILayout.ExpandHeight(false));
                
                for (int i = 0; i < ModelNames.Count; i++)
                {
                    EditorGUI.indentLevel = 1;
                    //ShowModeInfoStyle(i,new Rect(ItemRect.x, ItemRect.y + i * ItemRect.height, EditorHelper.visibleRect.width, ItemRect.height));
                    GUILayout.BeginVertical(EditorStyles.helpBox);
                    //GUILayout.BeginHorizontal(EditorStyles.helpBox);
                    ModelToggle[Models[ModelNames[i]].ModelName] = EditorGUILayout.Foldout(ModelToggle[Models[ModelNames[i]].ModelName], Models[ModelNames[i]].ModelName);
                    if(ModelToggle[Models[ModelNames[i]].ModelName])
                        ShowModeInfo(ModelNames[i], Models[ModelNames[i]]);
                    //GUILayout.EndHorizontal();
                    GUILayout.EndVertical();
                }
                GUILayout.EndScrollView();

            }
            GUILayout.EndHorizontal();
            this.Repaint();
        }
        protected virtual void ShowModeInfo(string ModelStr, ModelContorlBase Model)
        {
            var t = Model.GetType();
            FieldInfo[] properties = t.GetFields( BindingFlags.Default | BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
            EditorGUILayout.LabelField("模块名称", Model.ModelName);
            EditorGUILayout.LabelField("状态", Model.State.ToString());
            foreach (var item in properties)
            {
                SerializeObj(item, Model, item.GetValue(Model));
            }
            Model.ShowInspector();
            GUILayout.BeginVertical(EditorStyles.helpBox);
            ModelCompToggle[Model.ModelName] = EditorGUILayout.Foldout(ModelCompToggle[Model.ModelName], "组件列表");
            if (ModelCompToggle[Model.ModelName])
            {
                List<ModelCompBase> ModelComps = Model.GetMyComps();
                for (int i = 0; i < ModelComps.Count; i++)
                {
                    GUILayout.BeginVertical(EditorStyles.textField);
                    ShowCompInfo(ModelComps[i]);
                    GUILayout.EndVertical();
                }
            }
            GUILayout.EndVertical();
        }

        /// <summary>
        /// 显示组件信息
        /// </summary>
        /// <param name="Comp"></param>
        protected virtual void ShowCompInfo(ModelCompBase Comp)
        {
            var t = Comp.GetType();
            FieldInfo[] properties = t.GetFields(BindingFlags.Default | BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
            EditorGUILayout.LabelField("组件", t.Name.ToString());
            EditorGUILayout.LabelField("状态", Comp.State.ToString());
            foreach (var item in properties)
            {
                SerializeObj(item, Comp, item.GetValue(Comp));
            }
            Comp.ShowInspector();
        }


        /// <summary>
        /// 显示模块对象样式
        /// </summary>
        /// <param name="Index"></param>
        /// <param name="width"></param>
        /// <param name="heght"></param>
        public readonly GUIStyle listItemBackground2 = new GUIStyle("CN EntryBackEven");
        public int CurrIndex = -1;
        protected virtual void ShowModeInfoStyle(int Index,Rect Pos)
        {
            if (Event.current.type == EventType.MouseDown && Event.current.button == 0 && Pos.Contains(Event.current.mousePosition))
            {
                CurrIndex = Index;
                Event.current.Use();
                if (Event.current.clickCount == 2)
                {
                    ModelBaseEditor.CloseView();
                    ModelBaseEditor.ShowModelView(ModelNames[CurrIndex], Models[ModelNames[CurrIndex]],new Rect(Pos.x,Pos.y,300,500));
                }
            }
            if (Event.current.type == EventType.Repaint)
            {
                listItemBackground2.Draw(Pos, false, false, CurrIndex == Index, false);
            }
        }


        #region 反射显示字段
        private void SerializeObj(FieldInfo value,object Comp, object obj)
        {
            Type objtype = value.FieldType;
            object[] attributes = value.GetCustomAttributes(typeof(MFWModel_SerializeAttribute), true);
            if (attributes == null || attributes.Length == 0)
                return;
            object SerializeAttribute = attributes[0];
            bool IsWirte = (bool)SerializeAttribute.GetType().GetField("IsWrite").GetValue(SerializeAttribute);
            string Name = SerializeAttribute is MFWModel_SerializeNameAttribute ? (string)SerializeAttribute.GetType().GetField("Name").GetValue(SerializeAttribute) : value.Name;
            if (objtype == typeof(string))
            {
                if (IsWirte)
                    value.SetValue(Comp, EditorGUILayout.TextField(Name, (string)obj));
                else
                    EditorGUILayout.LabelField(Name, (string)obj);

            }
            else if (objtype == typeof(bool))
            {
                if (IsWirte)
                    value.SetValue(Comp, EditorGUILayout.Toggle(Name, (bool)obj));
                else
                    EditorGUILayout.Toggle(Name, (bool)obj);
            }
            else if (objtype.IsEnum)
            {
                if (IsWirte)
                    value.SetValue(Comp, EditorGUILayout.EnumPopup(Name, (Enum)obj));
                else
                    EditorGUILayout.EnumPopup(Name, (Enum)obj);
            }
            else if (objtype == typeof(byte) || objtype == typeof(int))
            {
                if (IsWirte)
                    value.SetValue(Comp, EditorGUILayout.IntField(Name, (int)obj));
                else
                    EditorGUILayout.IntField(Name, (int)obj);
            }
            else if (objtype == typeof(long))
            {
                if (IsWirte)
                    value.SetValue(Comp, EditorGUILayout.LongField(Name, (long)obj));
                else
                    EditorGUILayout.LongField(Name, (long)obj);
            }
            else if (objtype == typeof(float) || objtype == typeof(double))
            {
                if (IsWirte)
                    value.SetValue(Comp,EditorGUILayout.FloatField(Name, (float)obj));
                else
                    EditorGUILayout.FloatField(Name, (float)obj);
            }
            else if (objtype == typeof(Vector2))
            {
                if (IsWirte)
                    value.SetValue(Comp, EditorGUILayout.Vector2Field(Name, (Vector2)obj));
                else
                    EditorGUILayout.Vector2Field(Name, (Vector2)obj);
            }
            else if (objtype == typeof(Vector3))
            {
                if (IsWirte)
                    value.SetValue(Comp, EditorGUILayout.Vector2Field(Name, (Vector3)obj));
                else
                    EditorGUILayout.Vector2Field(Name, (Vector3)obj);
            }
            else if (objtype == typeof(Color32))
            {
                if (IsWirte)
                    value.SetValue(Comp, EditorGUILayout.ColorField(Name, (Color32)obj));
                else
                    EditorGUILayout.ColorField(Name, (Color32)obj);
            }
            else if (objtype.IsGenericType && objtype.GetGenericTypeDefinition() == typeof(Dictionary<,>))
            {
                EditorGUILayout.LabelField(Name + ": 字典列表");
            }
            else if (objtype.IsGenericType && objtype.GetGenericTypeDefinition() == typeof(List<>))
            {
                EditorGUILayout.LabelField(Name + ": 对象列表");
            }
            else
            {
                GUILayout.Label(Name + ": 对象没有序列化");
            }   
        }
        #endregion

    }
}

/*自带样式名称（string to GUIStyle）
    GUIStyle 'AboutWIndowLicenseLabel' 
    GUIStyle 'AC LeftArrow' 
    GUIStyle 'AC RightArrow' 
    GUIStyle 'AnimationCurveEditorBackground' 
    GUIStyle 'AnimationEventBackground' 
    GUIStyle 'AnimationEventTooltip' 
    GUIStyle 'AnimationEventTooltipArrow' 
    GUIStyle 'AnimationKeyframeBackground' 
    GUIStyle 'AnimationRowEven' 
    GUIStyle 'AnimationRowOdd' 
    GUIStyle 'AnimationSelectionTextField' 
    GUIStyle 'AnimationTimelineTick' 
    GUIStyle 'AnimPropDropdown' 
    GUIStyle 'AppToolbar' 
    GUIStyle 'AS TextArea' 
    GUIStyle 'AssetLabel' 
    GUIStyle 'AssetLabel Icon' 
    GUIStyle 'AssetLabel Partial' 
    GUIStyle 'BoldLabel' 
    GUIStyle 'BoldToggle' 
    GUIStyle 'ButtonLeft' 
    GUIStyle 'ButtonMid' 
    GUIStyle 'ButtonRight' 
    GUIStyle 'CN Box' 
    GUIStyle 'CN CountBadge' 
    GUIStyle 'CN EntryBackEven' 
    GUIStyle 'CN EntryBackOdd' 
    GUIStyle 'CN EntryError' 
    GUIStyle 'CN EntryInfo' 
    GUIStyle 'CN EntryWarn' 
    GUIStyle 'CN Message' 
    GUIStyle 'CN StatusError' 
    GUIStyle 'CN StatusInfo' 
    GUIStyle 'CN StatusWarn' 
    GUIStyle 'ColorField' 
    GUIStyle 'ColorPicker2DThumb' 
    GUIStyle 'ColorPickerBackground' 
    GUIStyle 'ColorPickerBox' 
    GUIStyle 'ColorPickerHorizThumb' 
    GUIStyle 'ColorPickerVertThumb' 
    GUIStyle 'Command' 
    GUIStyle 'CommandLeft' 
    GUIStyle 'CommandMid' 
    GUIStyle 'CommandRight' 
    GUIStyle 'ControlHighlight' 
    GUIStyle 'ControlLabel' 
    GUIStyle 'CurveEditorLabelTickmarks' 
    GUIStyle 'debug_layout_box' 
    GUIStyle 'dockarea' 
    GUIStyle 'dockareaOverlay' 
    GUIStyle 'dockareaStandalone' 
    GUIStyle 'Dopesheetkeyframe' 
    GUIStyle 'dragtab' 
    GUIStyle 'dragtabbright' 
    GUIStyle 'dragtabdropwindow' 
    GUIStyle 'DropDown' 
    GUIStyle 'DropDownButton' 
    GUIStyle 'ErrorLabel' 
    GUIStyle 'ExposablePopupItem' 
    GUIStyle 'ExposablePopupMenu' 
    GUIStyle 'EyeDropperHorizontalLine' 
    GUIStyle 'EyeDropperPickedPixel' 
    GUIStyle 'EyeDropperVerticalLine' 
    GUIStyle 'flow background' 
    GUIStyle 'flow navbar back' 
    GUIStyle 'flow navbar button' 
    GUIStyle 'flow navbar separator' 
    GUIStyle 'flow node 0' 
    GUIStyle 'flow node 0 on' 
    GUIStyle 'flow node 1' 
    GUIStyle 'flow node 1 on' 
    GUIStyle 'flow node 2' 
    GUIStyle 'flow node 2 on' 
    GUIStyle 'flow node 3' 
    GUIStyle 'flow node 3 on' 
    GUIStyle 'flow node 4' 
    GUIStyle 'flow node 4 on' 
    GUIStyle 'flow node 5' 
    GUIStyle 'flow node 5 on' 
    GUIStyle 'flow node 6' 
    GUIStyle 'flow node 6 on' 
    GUIStyle 'flow node hex 0' 
    GUIStyle 'flow node hex 0 on' 
    GUIStyle 'flow node hex 1' 
    GUIStyle 'flow node hex 1 on' 
    GUIStyle 'flow node hex 2' 
    GUIStyle 'flow node hex 2 on' 
    GUIStyle 'flow node hex 3' 
    GUIStyle 'flow node hex 3 on' 
    GUIStyle 'flow node hex 4' 
    GUIStyle 'flow node hex 4 on' 
    GUIStyle 'flow node hex 5' 
    GUIStyle 'flow node hex 5 on' 
    GUIStyle 'flow node hex 6' 
    GUIStyle 'flow node hex 6 on' 
    GUIStyle 'flow node titlebar' 
    GUIStyle 'flow overlay area left' 
    GUIStyle 'flow overlay area right' 
    GUIStyle 'flow overlay box' 
    GUIStyle 'flow overlay foldout' 
    GUIStyle 'flow overlay header lower left' 
    GUIStyle 'flow overlay header lower right' 
    GUIStyle 'flow overlay header upper left' 
    GUIStyle 'flow overlay header upper right' 
    GUIStyle 'flow shader in 0' 
    GUIStyle 'flow shader in 1' 
    GUIStyle 'flow shader in 2' 
    GUIStyle 'flow shader in 3' 
    GUIStyle 'flow shader in 4' 
    GUIStyle 'flow shader in 5' 
    GUIStyle 'flow shader node 0' 
    GUIStyle 'flow shader node 0 on' 
    GUIStyle 'flow shader out 0' 
    GUIStyle 'flow shader out 1' 
    GUIStyle 'flow shader out 2' 
    GUIStyle 'flow shader out 3' 
    GUIStyle 'flow shader out 4' 
    GUIStyle 'flow shader out 5' 
    GUIStyle 'flow target in' 
    GUIStyle 'flow triggerPin in' 
    GUIStyle 'flow triggerPin out' 
    GUIStyle 'flow var 0' 
    GUIStyle 'flow var 0 on' 
    GUIStyle 'flow var 1' 
    GUIStyle 'flow var 1 on' 
    GUIStyle 'flow var 2' 
    GUIStyle 'flow var 2 on' 
    GUIStyle 'flow var 3' 
    GUIStyle 'flow var 3 on' 
    GUIStyle 'flow var 4' 
    GUIStyle 'flow var 4 on' 
    GUIStyle 'flow var 5' 
    GUIStyle 'flow var 5 on' 
    GUIStyle 'flow var 6' 
    GUIStyle 'flow var 6 on' 
    GUIStyle 'flow varPin in' 
    GUIStyle 'flow varPin out' 
    GUIStyle 'flow varPin tooltip' 
    GUIStyle 'Foldout' 
    GUIStyle 'FoldOutPreDrop' 
    GUIStyle 'GameViewBackground' 
    GUIStyle 'Grad Down Swatch' 
    GUIStyle 'Grad Down Swatch Overlay' 
    GUIStyle 'Grad Up Swatch' 
    GUIStyle 'Grad Up Swatch Overlay' 
    GUIStyle 'grey_border' 
    GUIStyle 'GridList' 
    GUIStyle 'GridListText' 
    GUIStyle 'GridToggle' 
    GUIStyle 'GroupBox' 
    GUIStyle 'GUIEditor.BreadcrumbLeft' 
    GUIStyle 'GUIEditor.BreadcrumbMid' 
    GUIStyle 'GV Gizmo DropDown' 
    GUIStyle 'HeaderLabel' 
    GUIStyle 'HelpBox' 
    GUIStyle 'Hi Label' 
    GUIStyle 'HorizontalMinMaxScrollbarThumb' 
    GUIStyle 'hostview' 
    GUIStyle 'IN BigTitle' 
    GUIStyle 'IN BigTitle Inner' 
    GUIStyle 'IN ColorField' 
    GUIStyle 'IN DropDown' 
    GUIStyle 'IN Foldout' 
    GUIStyle 'IN FoldoutStatic' 
    GUIStyle 'IN Label' 
    GUIStyle 'IN LockButton' 
    GUIStyle 'IN ObjectField' 
    GUIStyle 'IN Popup' 
    GUIStyle 'IN RenderLayer' 
    GUIStyle 'IN SelectedLine' 
    GUIStyle 'IN TextField' 
    GUIStyle 'IN ThumbnailSelection' 
    GUIStyle 'IN ThumbnailShadow' 
    GUIStyle 'IN Title' 
    GUIStyle 'IN TitleText' 
    GUIStyle 'IN Toggle' 
    GUIStyle 'InnerShadowBg' 
    GUIStyle 'InvisibleButton' 
    GUIStyle 'LargeButton' 
    GUIStyle 'LargeButtonLeft' 
    GUIStyle 'LargeButtonMid' 
    GUIStyle 'LargeButtonRight' 
    GUIStyle 'LargeDropDown' 
    GUIStyle 'LargeLabel' 
    GUIStyle 'LargePopup' 
    GUIStyle 'LargeTextField' 
    GUIStyle 'LightmapEditorSelectedHighlight' 
    GUIStyle 'ListToggle' 
    GUIStyle 'LockedHeaderBackground' 
    GUIStyle 'LockedHeaderButton' 
    GUIStyle 'LockedHeaderLabel' 
    GUIStyle 'LODBlackBox' 
    GUIStyle 'LODCameraLine' 
    GUIStyle 'LODLevelNotifyText' 
    GUIStyle 'LODRendererAddButton' 
    GUIStyle 'LODRendererButton' 
    GUIStyle 'LODRendererRemove' 
    GUIStyle 'LODRenderersText' 
    GUIStyle 'LODSceneText' 
    GUIStyle 'LODSliderBG' 
    GUIStyle 'LODSliderRange' 
    GUIStyle 'LODSliderRangeSelected' 
    GUIStyle 'LODSliderText' 
    GUIStyle 'LODSliderTextSelected' 
    GUIStyle 'MeBlendBackground' 
    GUIStyle 'MeBlendPosition' 
    GUIStyle 'MeBlendTriangleLeft' 
    GUIStyle 'MeBlendTriangleRight' 
    GUIStyle 'MeLivePlayBackground' 
    GUIStyle 'MeLivePlayBar' 
    GUIStyle 'MenuItem' 
    GUIStyle 'MenuItemMixed' 
    GUIStyle 'MeTimeLabel' 
    GUIStyle 'MeTransBGOver' 
    GUIStyle 'MeTransitionBack' 
    GUIStyle 'MeTransitionBlock' 
    GUIStyle 'MeTransitionHandleLeft' 
    GUIStyle 'MeTransitionHandleLeftPrev' 
    GUIStyle 'MeTransitionHandleRight' 
    GUIStyle 'MeTransitionHead' 
    GUIStyle 'MeTransitionSelect' 
    GUIStyle 'MeTransitionSelectHead' 
    GUIStyle 'MeTransOff2On' 
    GUIStyle 'MeTransOffLeft' 
    GUIStyle 'MeTransOffRight' 
    GUIStyle 'MeTransOn2Off' 
    GUIStyle 'MeTransOnLeft' 
    GUIStyle 'MeTransOnRight' 
    GUIStyle 'MeTransPlayhead' 
    GUIStyle 'MiniBoldLabel' 
    GUIStyle 'minibutton' 
    GUIStyle 'minibuttonleft' 
    GUIStyle 'minibuttonmid' 
    GUIStyle 'minibuttonright' 
    GUIStyle 'MiniLabel' 
    GUIStyle 'MiniLabelRight' 
    GUIStyle 'MiniMinMaxSliderHorizontal' 
    GUIStyle 'MiniMinMaxSliderVertical' 
    GUIStyle 'MiniPopup' 
    GUIStyle 'MiniPullDown' 
    GUIStyle 'MiniPullDownLeft' 
    GUIStyle 'MiniTextField' 
    GUIStyle 'MiniToolbarButton' 
    GUIStyle 'MiniToolbarButtonLeft' 
    GUIStyle 'MiniToolbarPopup' 
    GUIStyle 'MinMaxHorizontalSliderThumb' 
    GUIStyle 'NotificationBackground' 
    GUIStyle 'NotificationText' 
    GUIStyle 'ObjectField' 
    GUIStyle 'ObjectFieldThumb' 
    GUIStyle 'ObjectFieldThumbOverlay' 
    GUIStyle 'ObjectFieldThumbOverlay2' 
    GUIStyle 'ObjectPickerBackground' 
    GUIStyle 'ObjectPickerGroupHeader' 
    GUIStyle 'ObjectPickerLargeStatus' 
    GUIStyle 'ObjectPickerPreviewBackground' 
    GUIStyle 'ObjectPickerResultsEven' 
    GUIStyle 'ObjectPickerResultsGrid' 
    GUIStyle 'ObjectPickerResultsGridLabel' 
    GUIStyle 'ObjectPickerResultsOdd' 
    GUIStyle 'ObjectPickerSmallStatus' 
    GUIStyle 'ObjectPickerTab' 
    GUIStyle 'ObjectPickerToolbar' 
    GUIStyle 'OL box' 
    GUIStyle 'OL box NoExpand' 
    GUIStyle 'OL Elem' 
    GUIStyle 'OL EntryBackEven' 
    GUIStyle 'OL EntryBackOdd' 
    GUIStyle 'OL header' 
    GUIStyle 'OL Label' 
    GUIStyle 'OL Minus' 
    GUIStyle 'OL Plus' 
    GUIStyle 'OL TextField' 
    GUIStyle 'OL Title' 
    GUIStyle 'OL Title TextRight' 
    GUIStyle 'OL Titleleft' 
    GUIStyle 'OL Titlemid' 
    GUIStyle 'OL Titleright' 
    GUIStyle 'OL Toggle' 
    GUIStyle 'OL ToggleWhite' 
    GUIStyle 'PaneOptions' 
    GUIStyle 'PlayerSettingsLevel' 
    GUIStyle 'PlayerSettingsPlatform' 
    GUIStyle 'Popup' 
    GUIStyle 'PopupBackground' 
    GUIStyle 'PopupCurveDropdown' 
    GUIStyle 'PopupCurveEditorBackground' 
    GUIStyle 'PopupCurveEditorSwatch' 
    GUIStyle 'PopupCurveSwatchBackground' 
    GUIStyle 'PR BrokenPrefabLabel' 
    GUIStyle 'PR DigDownArrow' 
    GUIStyle 'PR DisabledBrokenPrefabLabel' 
    GUIStyle 'PR DisabledLabel' 
    GUIStyle 'PR DisabledPrefabLabel' 
    GUIStyle 'PR Insertion' 
    GUIStyle 'PR Insertion Above' 
    GUIStyle 'PR Label' 
    GUIStyle 'PR Ping' 
    GUIStyle 'PR PrefabLabel' 
    GUIStyle 'PR TextField' 
    GUIStyle 'PreBackground' 
    GUIStyle 'PreButton' 
    GUIStyle 'PreDropDown' 
    GUIStyle 'PreferencesKeysElement' 
    GUIStyle 'PreferencesSection' 
    GUIStyle 'PreferencesSectionBox' 
    GUIStyle 'PreHorizontalScrollbar' 
    GUIStyle 'PreHorizontalScrollbarThumb' 
    GUIStyle 'PreLabel' 
    GUIStyle 'PreOverlayLabel' 
    GUIStyle 'PreSlider' 
    GUIStyle 'PreSliderThumb' 
    GUIStyle 'PreToolbar' 
    GUIStyle 'PreToolbar2' 
    GUIStyle 'PreVerticalScrollbar' 
    GUIStyle 'PreVerticalScrollbarThumb' 
    GUIStyle 'ProfilerBadge' 
    GUIStyle 'ProfilerLeftPane' 
    GUIStyle 'ProfilerLeftPaneOverlay' 
    GUIStyle 'ProfilerPaneLeftBackground' 
    GUIStyle 'ProfilerPaneSubLabel' 
    GUIStyle 'ProfilerRightPane' 
    GUIStyle 'ProfilerScrollviewBackground' 
    GUIStyle 'ProfilerSelectedLabel' 
    GUIStyle 'ProgressBarBack' 
    GUIStyle 'ProgressBarBar' 
    GUIStyle 'ProgressBarText' 
    GUIStyle 'ProjectBrowserBottomBarBg' 
    GUIStyle 'ProjectBrowserGridLabel' 
    GUIStyle 'ProjectBrowserHeaderBgMiddle' 
    GUIStyle 'ProjectBrowserHeaderBgTop' 
    GUIStyle 'ProjectBrowserIconAreaBg' 
    GUIStyle 'ProjectBrowserIconDropShadow' 
    GUIStyle 'ProjectBrowserPreviewBg' 
    GUIStyle 'ProjectBrowserSubAssetBg' 
    GUIStyle 'ProjectBrowserSubAssetBgCloseEnded' 
    GUIStyle 'ProjectBrowserSubAssetBgDivider' 
    GUIStyle 'ProjectBrowserSubAssetBgMiddle' 
    GUIStyle 'ProjectBrowserSubAssetBgOpenEnded' 
    GUIStyle 'ProjectBrowserSubAssetExpandBtn' 
    GUIStyle 'ProjectBrowserTextureIconDropShadow' 
    GUIStyle 'ProjectBrowserTopBarBg' 
    GUIStyle 'QualitySettingsDefault' 
    GUIStyle 'Radio' 
    GUIStyle 'RightLabel' 
    GUIStyle 'RL Background' 
    GUIStyle 'RL DragHandle' 
    GUIStyle 'RL Element' 
    GUIStyle 'RL Footer' 
    GUIStyle 'RL FooterButton' 
    GUIStyle 'RL Header' 
    GUIStyle 'SC ViewAxisLabel' 
    GUIStyle 'SC ViewLabel' 
    GUIStyle 'SceneViewOverlayTransparentBackground' 
    GUIStyle 'ScriptText' 
    GUIStyle 'SearchCancelButton' 
    GUIStyle 'SearchCancelButtonEmpty' 
    GUIStyle 'SearchModeFilter' 
    GUIStyle 'SearchTextField' 
    GUIStyle 'SelectionRect' 
    GUIStyle 'ServerChangeCount' 
    GUIStyle 'ServerUpdateChangeset' 
    GUIStyle 'ServerUpdateChangesetOn' 
    GUIStyle 'ServerUpdateInfo' 
    GUIStyle 'ServerUpdateLog' 
    GUIStyle 'ShurikenCheckMark' 
    GUIStyle 'ShurikenDropdown' 
    GUIStyle 'ShurikenEffectBg' 
    GUIStyle 'ShurikenEmitterTitle' 
    GUIStyle 'ShurikenLabel' 
    GUIStyle 'ShurikenLine' 
    GUIStyle 'ShurikenMinus' 
    GUIStyle 'ShurikenModuleBg' 
    GUIStyle 'ShurikenModuleTitle' 
    GUIStyle 'ShurikenObjectField' 
    GUIStyle 'ShurikenPlus' 
    GUIStyle 'ShurikenPopup' 
    GUIStyle 'ShurikenToggle' 
    GUIStyle 'ShurikenValue' 
    GUIStyle 'SimplePopup' 
    GUIStyle 'SliderMixed' 
    GUIStyle 'StaticDropdown' 
    GUIStyle 'sv_iconselector_back' 
    GUIStyle 'sv_iconselector_button' 
    GUIStyle 'sv_iconselector_labelselection' 
    GUIStyle 'sv_iconselector_selection' 
    GUIStyle 'sv_iconselector_sep' 
    GUIStyle 'sv_label_0' 
    GUIStyle 'sv_label_1' 
    GUIStyle 'sv_label_2' 
    GUIStyle 'sv_label_3' 
    GUIStyle 'sv_label_4' 
    GUIStyle 'sv_label_5' 
    GUIStyle 'sv_label_6' 
    GUIStyle 'sv_label_7' 
    GUIStyle 'TabWindowBackground' 
    GUIStyle 'Tag MenuItem' 
    GUIStyle 'Tag TextField' 
    GUIStyle 'Tag TextField Button' 
    GUIStyle 'Tag TextField Empty' 
    GUIStyle 'TE NodeBackground' 
    GUIStyle 'TE NodeBox' 
    GUIStyle 'TE NodeBoxSelected' 
    GUIStyle 'TE NodeLabelBot' 
    GUIStyle 'TE NodeLabelTop' 
    GUIStyle 'TE PinLabel' 
    GUIStyle 'TE Toolbar' 
    GUIStyle 'TE toolbarbutton' 
    GUIStyle 'TE ToolbarDropDown' 
    GUIStyle 'TimeScrubber' 
    GUIStyle 'TimeScrubberButton' 
    GUIStyle 'TL BaseStateLogicBarOverlay' 
    GUIStyle 'TL EndPoint' 
    GUIStyle 'TL InPoint' 
    GUIStyle 'TL ItemTitle' 
    GUIStyle 'TL LeftColumn' 
    GUIStyle 'TL LeftItem' 
    GUIStyle 'TL LogicBar 0' 
    GUIStyle 'TL LogicBar 1' 
    GUIStyle 'TL LogicBar parentgrey' 
    GUIStyle 'TL LoopSection' 
    GUIStyle 'TL OutPoint' 
    GUIStyle 'TL Playhead' 
    GUIStyle 'TL Range Overlay' 
    GUIStyle 'TL RightLine' 
    GUIStyle 'TL Selection H1' 
    GUIStyle 'TL Selection H2' 
    GUIStyle 'TL SelectionBarCloseButton' 
    GUIStyle 'TL SelectionBarPreview' 
    GUIStyle 'TL SelectionBarText' 
    GUIStyle 'TL SelectionButton' 
    GUIStyle 'TL SelectionButton PreDropGlow' 
    GUIStyle 'TL SelectionButtonName' 
    GUIStyle 'TL SelectionButtonNew' 
    GUIStyle 'TL tab left' 
    GUIStyle 'TL tab mid' 
    GUIStyle 'TL tab plus left' 
    GUIStyle 'TL tab plus right' 
    GUIStyle 'TL tab right' 
    GUIStyle 'ToggleMixed' 
    GUIStyle 'Toolbar' 
    GUIStyle 'toolbarbutton' 
    GUIStyle 'ToolbarDropDown' 
    GUIStyle 'ToolbarPopup' 
    GUIStyle 'ToolbarSeachCancelButton' 
    GUIStyle 'ToolbarSeachCancelButtonEmpty' 
    GUIStyle 'ToolbarSeachTextField' 
    GUIStyle 'ToolbarSeachTextFieldPopup' 
    GUIStyle 'ToolbarSearchField' 
    GUIStyle 'ToolbarTextField' 
    GUIStyle 'Tooltip' 
    GUIStyle 'U2D.createRect' 
    GUIStyle 'U2D.dragDot' 
    GUIStyle 'U2D.dragDotActive' 
    GUIStyle 'U2D.dragDotDimmed' 
    GUIStyle 'U2D.pivotDot' 
    GUIStyle 'U2D.pivotDotActive' 
    GUIStyle 'VCS_StickyNote' 
    GUIStyle 'VCS_StickyNoteArrow' 
    GUIStyle 'VCS_StickyNoteLabel' 
    GUIStyle 'VCS_StickyNoteP4' 
    GUIStyle 'VerticalMinMaxScrollbarThumb' 
    GUIStyle 'VisibilityToggle' 
    GUIStyle 'WhiteBoldLabel' 
    GUIStyle 'WhiteLabel' 
    GUIStyle 'WhiteLargeLabel' 
    GUIStyle 'WhiteMiniLabel' 
    GUIStyle 'WinBtnCloseActiveMac' 
    GUIStyle 'WinBtnCloseMac' 
    GUIStyle 'WinBtnCloseWin' 
    GUIStyle 'WinBtnInactiveMac' 
    GUIStyle 'WinBtnMaxActiveMac' 
    GUIStyle 'WinBtnMaxMac' 
    GUIStyle 'WinBtnMaxWin' 
    GUIStyle 'WinBtnMinActiveMac' 
    GUIStyle 'WinBtnMinMac' 
    GUIStyle 'WinBtnMinWin' 
    GUIStyle 'WindowBackground' 
    GUIStyle 'WindowBottomResize' 
    GUIStyle 'WindowResizeMac' 
    GUIStyle 'Wizard Box' 
    GUIStyle 'Wizard Error' 
    GUIStyle 'WordWrapLabel' 
    GUIStyle 'WordWrappedLabel' 
    GUIStyle 'WordWrappedMiniLabel' 
    GUIStyle 'WrappedLabel'   
*/

/* 内置图标
TreeEditor.AddLeaves
TreeEditor.AddBranches
TreeEditor.Trash
TreeEditor.Duplicate
TreeEditor.Refresh
editicon.sml
tree_icon_branch_frond
tree_icon_branch
tree_icon_frond
tree_icon_leaf
tree_icon
animationvisibilitytoggleon
animationvisibilitytoggleoff
MonoLogo
AgeiaLogo
AboutWindow.MainHeader
Animation.AddEvent
lightMeter/greenLight
lightMeter/lightRim
lightMeter/orangeLight
lightMeter/redLight
Animation.PrevKey
Animation.NextKey
Animation.AddKeyframe
Animation.EventMarker
Animation.Play
Animation.Record
AS Badge Delete
AS Badge Move
AS Badge New
WelcomeScreen.AssetStoreLogo
preAudioAutoPlayOff
preAudioAutoPlayOn
preAudioPlayOff
preAudioPlayOn
preAudioLoopOff
preAudioLoopOn
AvatarInspector/BodySilhouette
AvatarInspector/HeadZoomSilhouette
AvatarInspector/LeftHandZoomSilhouette
AvatarInspector/RightHandZoomSilhouette
AvatarInspector/Torso
AvatarInspector/Head
AvatarInspector/LeftArm
AvatarInspector/LeftFingers
AvatarInspector/RightArm
AvatarInspector/RightFingers
AvatarInspector/LeftLeg
AvatarInspector/RightLeg
AvatarInspector/HeadZoom
AvatarInspector/LeftHandZoom
AvatarInspector/RightHandZoom
AvatarInspector/DotFill
AvatarInspector/DotFrame
AvatarInspector/DotFrameDotted
AvatarInspector/DotSelection
SpeedScale
AvatarPivot
Avatar Icon
Mirror
AvatarInspector/BodySIlhouette
AvatarInspector/BodyPartPicker
AvatarInspector/MaskEditor_Root
AvatarInspector/LeftFeetIk
AvatarInspector/RightFeetIk
AvatarInspector/LeftFingersIk
AvatarInspector/RightFingersIk
BuildSettings.SelectedIcon
SocialNetworks.UDNLogo
SocialNetworks.LinkedInShare
SocialNetworks.FacebookShare
SocialNetworks.Tweet
SocialNetworks.UDNOpen
Clipboard
Toolbar Minus
ClothInspector.PaintValue
EditCollider
EyeDropper.Large
ColorPicker.CycleColor
ColorPicker.CycleSlider
PreTextureMipMapLow
PreTextureMipMapHigh
PreTextureAlpha
PreTextureRGB
Icon Dropdown
UnityLogo
Profiler.PrevFrame
Profiler.NextFrame
GameObject Icon
Prefab Icon
PrefabNormal Icon
PrefabModel Icon
ScriptableObject Icon
sv_icon_none
PreMatLight0
PreMatLight1
Toolbar Plus
Camera Icon
PreMatSphere
PreMatCube
PreMatCylinder
PreMatTorus
PlayButton
PauseButton
HorizontalSplit
VerticalSplit
BuildSettings.Web.Small
js Script Icon
cs Script Icon
boo Script Icon
Shader Icon
TextAsset Icon
AnimatorController Icon
AudioMixerController Icon
RectTransformRaw
RectTransformBlueprint
MoveTool
MeshRenderer Icon
Terrain Icon
SceneviewLighting
SceneviewFx
SceneviewAudio
SettingsIcon
TerrainInspector.TerrainToolRaise
TerrainInspector.TerrainToolSetHeight
TerrainInspector.TerrainToolSmoothHeight
TerrainInspector.TerrainToolSplat
TerrainInspector.TerrainToolTrees
TerrainInspector.TerrainToolPlants
TerrainInspector.TerrainToolSettings
RotateTool
ScaleTool
RectTool
MoveTool On
RotateTool On
ScaleTool On
RectTool On
ViewToolOrbit
ViewToolMove
ViewToolZoom
ViewToolOrbit On
ViewToolMove On
ViewToolZoom On
StepButton
PlayButtonProfile
PlayButton On
PauseButton On
StepButton On
PlayButtonProfile On
PlayButton Anim
PauseButton Anim
StepButton Anim
PlayButtonProfile Anim
WelcomeScreen.MainHeader
WelcomeScreen.VideoTutLogo
WelcomeScreen.UnityBasicsLogo
WelcomeScreen.UnityForumLogo
WelcomeScreen.UnityAnswersLogo
Toolbar Plus More 
*/

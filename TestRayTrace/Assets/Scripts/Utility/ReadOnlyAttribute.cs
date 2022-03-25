
using UnityEngine;
#if (UNITY_EDITOR)
using UnityEditor;
#endif

namespace XUtility
{

    /// <summary>
    /// ֻ�����Թ�����
    /// </summary>
    public class ReadOnlyAttribute : PropertyAttribute { }
#if (UNITY_EDITOR)
    /// <summary>
    /// ������
    /// </summary>
    [CustomPropertyDrawer(typeof(ReadOnlyAttribute))]
    public class ReadOnlyDrawer : PropertyDrawer
    {
        /// <summary>
        /// ��������ԭ�и߶�
        /// </summary>
        /// <param name="property"></param>
        /// <param name="label"></param>
        /// <returns></returns>
        public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
        {
            return EditorGUI.GetPropertyHeight(property, label, true);
        }

        /// <summary>
        /// ֻ��
        /// </summary>
        /// <param name="position"></param>
        /// <param name="property"></param>
        /// <param name="label"></param>
        public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
        {
            GUI.enabled = false;
            EditorGUI.PropertyField(position, property, label, true);
            GUI.enabled = true;
        }
    }
#endif
}
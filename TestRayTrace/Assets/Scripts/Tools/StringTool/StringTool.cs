using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace StringTool
{
    public static class StringHelper
    {
        public static string ChopEnd(string str, string postFix)
        {
            int len = str.Length - postFix.Length;
            int inx = str.IndexOf(postFix);
            if (inx != len)
            {
                Debug.LogError("Not postFix");
                return "";
            }
            return str.Substring(0, len);
        }

        public static string ChopBegin(string str, string preFix)
        {
            return str.Substring(preFix.Length, str.Length - preFix.Length);
        }
    }
}
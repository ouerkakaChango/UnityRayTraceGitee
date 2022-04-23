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

        //去除多余空格，tab
        //去除开头结尾的空格，tab
        public static string NiceLine(string str)
        {
            char[] charSeparators = new char[] { ' ', '\t' };
            string[] words = str.Split(charSeparators, System.StringSplitOptions.RemoveEmptyEntries);
            return string.Join(" ", words);
        }
    }
}
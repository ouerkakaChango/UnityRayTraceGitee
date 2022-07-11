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

        public static void Append(ref string re, in string[] lines)
        {
            for(int i=0;i<lines.Length;i++)
            {
                re += lines[i];
                re += "\n";
            }
        }

        public static void Append(ref string re, in List<string> lines)
        {
            for (int i = 0; i < lines.Count; i++)
            {
                re += lines[i];
                re += "\n";
            }
        }

        public static string GetFileName(string path, string postfix)
        {
            if(!path.EndsWith(postfix))
            {
                Debug.LogError("post fix not correct");
                return "";
            }
            int i1 = postfix.Length;
            int l1 = path.Length - 1;
            int i2 = -1;
            for(int idx = i1;idx<path.Length;idx++)
            {
                char c = path[l1 - idx];
                if(c == '\\'||c=='/')
                {
                    i2 = idx-1;
                    break;
                }
            }
            if(i2 == -1)
            {
                Debug.LogError("not a folder path");
                return "";
            }
            return path.Substring(l1 - i2, i2 - i1 + 1);
        }
    }
}
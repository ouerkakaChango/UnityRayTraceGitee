using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace StringTool
{
    public static class StringHelper
    {
        public static string ChopEnd(string str, string postFix, bool strict=true)
        {
            int len = str.Length - postFix.Length;
            int inx = str.IndexOf(postFix);
            if (inx != len)
            {
                if (strict)
                {
                    Debug.LogError("Not postFix");
                    return "";
                }
                else
                {
                    return str;
                }
            }
            return str.Substring(0, len);
        }

        public static string ChopBegin(string str, string preFix)
        {
            return str.Substring(preFix.Length, str.Length - preFix.Length);
        }

        //去除多余空格，tab
        //去除开头结尾的空格，tab
        //之后，如果有if (..)，去除if后面的空格
        //之后，如果有"( "," )"，去除空格
        public static string NiceLine(string str)
        {
            char[] charSeparators = new char[] { ' ', '\t' };
            string[] words = str.Split(charSeparators, System.StringSplitOptions.RemoveEmptyEntries);
            string re = string.Join(" ", words);
            if(re.Length>4 && re.Substring(0,4)=="if (")
            {
                re = "if(" + re.Substring(4);
            }
            re = re.Replace(" if (", " if(");
            re = re.Replace("( ", "(");
            re = re.Replace(" )", ")");
            return re;
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
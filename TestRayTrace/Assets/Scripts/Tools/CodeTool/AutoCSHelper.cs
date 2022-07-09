using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using StringTool;

public static class AutoCSHelper
{
   public static List<string> GetBlockCode(ref string[] lines, string blockName)
    {
        List<string> re = new List<string>();
        bool hasBegin = false;
        for (int i=0;i<lines.Length;i++)
        {
            var line = StringHelper.NiceLine(lines[i]);
            if(!hasBegin && line == "###BLOCK "+blockName)
            {
                hasBegin = true;
                continue;
            }
            if(hasBegin && line == "###BLOCK")
            {
                break;
            }
            if(hasBegin)
            {
                re.Add(lines[i]);
            }
        }
        return re;
    }
}

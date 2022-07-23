using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using StringTool;

namespace CodeTool
{
    public static class SDFPrefabMergeHelper
    {
        //re = min(re, 0 + SDFBox(p, float3(0.284, 0.1, 0.5), float3(0.05, 0.1, 0.35), float3(0, 0, 0)));
        public static List<string> MergeSDFBox(Dictionary<int, List<string>> boxLines)
        {
            List<string> re = new List<string>();
            var idList = boxLines.Keys.ToList();
            for (int i = 0; i < idList.Count; i++)
            {
                string idstr = "d" + idList[i];
                re.Add("float " + idstr + " = re;");
            }
            for (int i = 0; i < idList.Count; i++)
            {
                int id = idList[i];
                string idstr = "d" + id;
                var line = boxLines[id][0];
                line = line.Replace("re", idstr);
                re.Add(line);
            }
            return re;
        }

        public static List<string> MergeSDFQuadBezier(Dictionary<int, List<string>> qbLines)
        {
            List<string> re = new List<string>();
            var idList = qbLines.Keys.ToList();
            for (int i = 0; i < idList.Count; i++)
            {
                int id = idList[i];
                //1.将d换成d_[id]
                //ori: float d = re;
                //new: float d[id] = re;
                var lines = qbLines[id];
                CodeHelper.ReplaceIn(ref lines, "float d = re;", "d", "d" + idList[i]);
                //ori: FUNC_SDFBoxedQuadBezier(d, p, spline, 9, trans, box)
                //new: FUNC_SDFBoxedQuadBezier(d[id], p, spline, 9, trans, box)
                CodeHelper.ReplaceIn(ref lines, "FUNC_SDFBoxedQuadBezier(d,", "d,", "d" + idList[i]+",",MatchPattern.partLine);
                //2.删除re = min(re,d);
                CodeHelper.RemoveIn(ref lines, "re = min(re,d);");
                qbLines[id] = lines;
                re.AddRange(lines);
            }

            //3.非数组变量声明删重
            CodeHelper.CodeSimplify(ref re, CodeLineType.SingleValStatement, CodeSimplifyOp.RemoveRedundantStatement);
            //4.数组变量删重
            CodeHelper.CodeSimplify(ref re, CodeLineType.ArrayValStatementAndInit, CodeSimplifyOp.RemoveRedundantStatementAndInit);
            return re;
        }
    }
}
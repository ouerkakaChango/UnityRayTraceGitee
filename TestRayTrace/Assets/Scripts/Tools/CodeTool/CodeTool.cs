using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System;
using UnityEngine;
using StringTool;
using Debugger;

namespace CodeTool
{
    public enum CodeLineType
    {
        SingleValStatement, // not array val
    };

    public enum CodeSimplifyOp
    {
        RemoveRedundant, //keep first,remove rest all
    };

    public enum CodeLineOpType
    {
        Remove,
        ChopType,
    };

    public struct CodeLineOp
    {
        public int inx;
        public CodeLineOpType type;

        public CodeLineOp(int _inx, CodeLineOpType _type)
        {
            inx = _inx;
            type = _type;
        }

        public override string ToString()
        {
            return Enum.GetName(typeof(CodeLineOpType), type) + " " + inx;
        }
    }

    public static class CodeHelper
    {
        //if nice line,even though head is slightly diffentent(spacebar,tab...) is ok.
        public static List<string> GetBlockOfHead(ref List<string> lines, string head, bool niceLineJudgeHead = true, bool addHead = false)
        {
            List<string> re = new List<string>();
            if (addHead)
            {
                re.Add(head);
                re.Add("{");
            }
            if (niceLineJudgeHead)
            {
                head = StringHelper.NiceLine(head);
            }
            bool hasBegin = false;
            int brace = 0;
            for(int i=0;i<lines.Count;i++)
            {
                var line = lines[i];
                if(niceLineJudgeHead)
                {
                    line = StringHelper.NiceLine(line);
                }
                if(!hasBegin && i + 1>=lines.Count)
                {
                    break;
                }
                var next = lines[i + 1];
                if(niceLineJudgeHead)
                {
                    next = StringHelper.NiceLine(next);
                }
                //Debug.Log(line+"\n"+head);
                if (!hasBegin && line == head && next == "{")
                {
                    //Debug.Log("hasBegin");
                    hasBegin = true;
                    i += 1;
                    continue;
                }

                if(hasBegin)
                {
                    re.Add(lines[i]);
                }

                if(hasBegin && line == "{")
                {
                    brace += 1;
                }

                if (hasBegin && line == "}")
                {
                    brace -= 1;
                }

                if (hasBegin && next == "}" && brace == 0)
                {
                    break;
                }
            }

            if (addHead)
            {
                re.Add("}");
            }
            return re;
        }

        public static void ConvertToNiceLines(ref List<string> lines)
        {
            for(int i=0;i<lines.Count;i++)
            {
                lines[i] = StringHelper.NiceLine(lines[i]);
            }
        }

        public static string RemoveComment(string line)
        {
            string re = "";
            for(int i=0;i<line.Length;i++)
            {
                if (i + 1 < line.Length && line[i]=='/'&&line[i+1]=='/')
                {
                    break;
                }
                re += line[i];
            }
            return re;
        }

        //??? 多行注释/* */未支持
        public static void RemoveComments(ref List<string> lines)
        {
            List<string> re = new List<string>();
            //1.去除//注释
            for(int i=0;i<lines.Count;i++)
            {
                var line = RemoveComment(lines[i]);
                if(StringHelper.NiceLine(line).Length>0)
                {
                    re.Add(line);
                }
            }
            lines = re;
            //??? 2.去除/* */注释
        }

        public static bool ValidFuncName(string name)
        {
            if(name.Contains(",")||name.Contains(";"))
            {
                return false;
            }
            return true;
        }

        //format:XXX(param1,param2,...);
        public static bool ParseFuncLine(string line, out string funcName, out List<string> paramList, bool hasSemicolon = true)
        {
            funcName = "";
            paramList = new List<string>();
            bool inFunc = true;
            string temp = "";
            int i = 0;
            int condi = 0;
            int paramBcount = 0;
            for (;i<line.Length;i++)
            {
                if(inFunc)
                {
                    if (line[i] != '(')
                    {
                        funcName += line[i];
                    }
                    else
                    {
                        inFunc = false;
                        if(!ValidFuncName(funcName))
                        {
                            return false;
                        }
                        //必须有一个(
                        condi += 1;
                        continue;
                    }
                }
                else
                {
                    if(line[i]!=',')
                    {
                        if (line[i] == ')')
                        {
                            if (paramBcount == 0)
                            {
                                paramList.Add(temp);
                                //必须有一个)
                                condi += 1;
                                break;
                            }
                            else
                            {//属于参数中的)
                                temp += line[i];
                                paramBcount -= 1;
                            }
                        }
                        else
                        {
                            temp += line[i];
                            if(line[i]=='(')
                            {
                                paramBcount += 1;
                            }
                        }
                    }
                    else
                    {
                        paramList.Add(temp);
                        temp = "";
                    }
                }
            }

            if(paramBcount == 0 && condi == 2)
            {
                //continue;
            }
            else
            {
                return false;
            }

            if(hasSemicolon)
            {
                return (i == line.Length - 2 && line[i + 1] == ';');
            }
            else
            {
                return i == line.Length - 1;
            }
        }

        public static void ReplaceIn(ref List<string> lines,string wholestr,string oldstr,string newstr)
        {
            for(int i=0;i<lines.Count;i++)
            {
                var line = lines[i];
                line = StringHelper.NiceLine(line);
                if(line == wholestr)
                {
                    //Debug.Log("Match!");
                    line = line.Replace(oldstr, newstr);
                }
                lines[i] = line;
            }
        }

        public static void RemoveIn(ref List<string> lines, string wholestr)
        {
            lines.RemoveAll(i => i == wholestr);
        }

        public static void CodeSimplify(ref List<string> lines, CodeLineType targetType, CodeSimplifyOp targetOp)
        {
            if(targetType== CodeLineType.SingleValStatement && targetOp == CodeSimplifyOp.RemoveRedundant)
            {
                //1.删除多余的单值声明
                Dictionary<string, Dictionary<string,Dictionary<string,List<int>>>> valMap = new Dictionary<string, Dictionary<string, Dictionary<string, List<int>>>>();
                for(int i=0;i<lines.Count;i++)
                {
                    var line = lines[i];
                    string type, valName, value;
                    if(IsSingleValStatement(line,out type, out valName, out value))
                    {
                        if(!valMap.ContainsKey(type))
                        {
                            valMap.Add(type, new Dictionary<string, Dictionary<string, List<int>>>());
                        }
                        if(!valMap[type].ContainsKey(valName))
                        {
                            valMap[type].Add(valName, new Dictionary<string, List<int>>());
                        }
                        if(!valMap[type][valName].ContainsKey(value))
                        {
                            valMap[type][valName].Add(value, new List<int>());
                        }
                        valMap[type][valName][value].Add(i);
                        //Debug.Log("add: " + type + " " + valName + " " + value);
                    }
                }
                //1.1.如果声明后面的赋值是一致的，则删除多余
                //1.2.如果声明后面的赋值是不一致，则删除非首次的声明类型，转为赋值语句
                List<CodeLineOp> op = new List<CodeLineOp>();
                foreach(var itype in valMap)
                {
                    string type = itype.Key;
                    foreach(var ivalName in itype.Value)
                    {
                        string valName = ivalName.Key;
                        foreach(var ivalue in ivalName.Value)
                        {
                            string value = ivalue.Key;
                            List<int> lineInx = ivalue.Value;
                            if(lineInx.Count>1)
                            {
                                Debug.Log("Redundant whole: "+valName+"%%"+value);
                            }
                            for(int i=1;i<lineInx.Count;i++)
                            {
                                //删除所有全重复声明
                                op.Add(new CodeLineOp(lineInx[i],CodeLineOpType.Remove));
                            }
                        }
                        var valueList = ivalName.Value.Keys.ToList();
                        if(valueList.Count>1)
                        {
                            Debug.Log("Redundant name with different value: " + valName );
                            for(int i=1;i<valueList.Count;i++)
                            {
                                string value = valueList[i];
                                //由于前面已删除全重复声明，所以取[0]就行
                                op.Add(new CodeLineOp(ivalName.Value[value][0], CodeLineOpType.Remove));
                            }
                        }
                    }
                }
                //2.删除重复的变量赋值

                //??? debug log op
                string tt = "";
                for(int i=0;i<op.Count;i++)
                {
                    tt += op[i].ToString() + "\n";
                }
                Debug.Log(tt);
                //___
            }
        }

        public static bool IsSingleValStatement(string line, out string type, out string valName, out string value)
        {
            type = "";
            valName = "";
            value = "";
            char[] charSeparators = new char[] { ' ', '\t' };
            line = StringHelper.ChopEnd(line,";", false);
            string[] words = line.Split(charSeparators, System.StringSplitOptions.RemoveEmptyEntries);
            //Debug.Log("LINE: " + line);
            //Log.DebugWords(words);
            bool re = false;
            if(words.Length>=4 && words[2]=="=")
            {
                re = true;
                type = words[0];
                valName = words[1];
                if(IsArrayWord(valName))
                {
                    return false;
                }
                for (int i=3;i<words.Length;i++)
                {
                    value += words[i];
                }
            }

            if(words.Length == 2)
            {
                re = true;
                type = words[0];
                valName = words[1];
                if (IsArrayWord(valName))
                {
                    return false;
                }
            }

            //if(re)
            //{
            //    Debug.Log(line);
            //}
            return re;
        }

        //匹配数组变量名，如float2 spline[3]的spline[3]
        //[_a-z]\\w* 匹配spline
        //[\\[][0-9][\\]] 匹配[3]
        public static bool IsArrayWord(string str)
        {
            bool re = Regex.Match(str, "^[_a-z]\\w*[\\[][0-9][\\]]$").Success;
            //if(re)
            //{
            //    Debug.Log("Match Array world!!! " + str);
            //}
            return re;
        }
    }
}
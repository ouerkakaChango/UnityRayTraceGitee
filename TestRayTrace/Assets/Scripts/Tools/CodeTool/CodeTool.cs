using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using StringTool;

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
                //删除多余的单值声明
                //???
            }
        }
    }
}
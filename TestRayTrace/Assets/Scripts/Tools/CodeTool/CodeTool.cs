using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using StringTool;

namespace CodeTool
{
    public static class CodeHelper
    {
        //if nice line,even though head is slightly diffentent(spacebar,tab...) is ok.
        public static List<string> GetBlockOfHead(ref List<string> lines, string head, bool niceLine = true)
        {
            List<string> re = new List<string>();
            if(niceLine)
            {
                head = StringHelper.NiceLine(head);
            }
            bool hasBegin = false;
            int brace = 0;
            for(int i=0;i<lines.Count;i++)
            {
                var line = lines[i];
                if(niceLine)
                {
                    line = StringHelper.NiceLine(line);
                }
                if(!hasBegin && i + 1>=lines.Count)
                {
                    break;
                }
                var next = lines[i + 1];
                if(niceLine)
                {
                    next = StringHelper.NiceLine(next);
                }

                if (!hasBegin && line == head && next == "{")
                {
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

        //??? ����ע��/* */δ֧��
        public static void RemoveComments(ref List<string> lines)
        {
            List<string> re = new List<string>();
            //1.ȥ��//ע��
            for(int i=0;i<lines.Count;i++)
            {
                var line = RemoveComment(lines[i]);
                if(StringHelper.NiceLine(line).Length>0)
                {
                    re.Add(line);
                }
            }
            lines = re;
            //??? 2.ȥ��/* */ע��
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
                        //������һ��(
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
                                //������һ��)
                                condi += 1;
                                break;
                            }
                            else
                            {//���ڲ����е�)
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
    }
}
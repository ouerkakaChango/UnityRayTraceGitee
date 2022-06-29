using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System;
using System.IO;
using System.Linq;
using UnityEngine;
using static StringTool.StringHelper;
using Debug = UnityEngine.Debug;

using XUtility;

//[ExecuteInEditMode]
public class AutoCS : MonoBehaviour
{
    public SDFBakerMgr bakerMgr = null;
    public List<string> templates = new List<string>();
    public List<string> outs = new List<string>();
    public List<string> cfgs = new List<string>();

    public string outTaskFilePath;

    Dictionary<string, List<Vector2Int>> rangeMap = new Dictionary<string, List<Vector2Int>>();

    [HideInInspector]
    public TextureSystem texSys;
    private void Awake()
    {
        //Generate();
    }

    // Start is called before the first frame update
    void Start()
    {
        //Generate();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //##########################################
    string FullPath(string localPath)
    {
        return Application.dataPath + "/" + localPath;
    }

    public void InitOuts()
    {
        outs.Clear();
        for (int i = 0; i < templates.Count; i++)
        {
            outs.Add("");
        }
    }

    string GetTaskString()
    {
        string re = "";
        re += "templates:\n";
        for (int i = 0; i < templates.Count; i++)
        {
            re += FullPath(templates[i]) + "\n";
        }
        re += "\n";
        re += "outs:\n";
        for (int i = 0; i < outs.Count; i++)
        {
            re += FullPath(outs[i]) + "\n";
        }

        re += "\n";
        re += "configs:\n";
        for (int i = 0; i < outs.Count; i++)
        {
            re += FullPath(cfgs[i]) + "\n";
        }
        return re;
    }

    void MakeTaskFile()
    {
        string path = FullPath(outTaskFilePath);
        if (File.Exists(path))
        {
            File.Delete(path);
        }
        File.WriteAllText(path, GetTaskString());
    }

    public void Generate()
    {
        //将templates,outs等写入config
        //调用外部控制台程序exe，进行config+templates => outs

        if(bakerMgr!=null)
        {
            bakerMgr.Bake();
            PreCompile();
        }
        MakeTaskFile();
        CallExe();
        ClearMemory();
    }

    void CallExe()
    {
        try
        {
            Process myProcess = new Process();
            myProcess.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
            myProcess.StartInfo.CreateNoWindow = true;
            myProcess.StartInfo.UseShellExecute = false;
            //??? 测试阶段
            {
                //myProcess.StartInfo.FileName = Application.dataPath +"/CmdExe/AutoCS.exe";
                myProcess.StartInfo.FileName = "C:\\Personal\\ParticleToy\\x64\\Debug\\ParticleToy.exe";
            }
            myProcess.StartInfo.WorkingDirectory = Application.dataPath + "/CmdExe";
            myProcess.StartInfo.Arguments = FullPath(outTaskFilePath);
            //Debug.Log(FullPath(outTaskFilePath));
            myProcess.EnableRaisingEvents = true;
            myProcess.Start();
            myProcess.WaitForExit();
            UnityEngine.Debug.Log("AutoCS已经运行关闭了");
            int ExitCode = myProcess.ExitCode;
            print(ExitCode);
        }
        catch (Exception e)
        {
            print(e);
        }
    }

    void PreCompile()
    {
        //Debug.Log("AutoCS PreCompile");
        for(int i=0;i<cfgs.Count;i++)
        {
            PreCompile(FullPath(cfgs[i]), i);
        }
        
    }

    void PreCompile(string path, int fileInx)
    {
        Debug.Log("###Precompile File: "+ path);
        //1.Load Files to string[]
        var lines = File.ReadAllLines(path);

        rangeMap.Clear();
        //!!! 顺序必须对应cgf
        rangeMap.Add("ValMaps", new List<Vector2Int>());
        rangeMap.Add("ObjMaterial", new List<Vector2Int>());
        rangeMap.Add("ObjRenderMode", new List<Vector2Int>());
        rangeMap.Add("ObjRender", new List<Vector2Int>());
        rangeMap.Add("DirShadow", new List<Vector2Int>());
        rangeMap.Add("ObjSDF", new List<Vector2Int>());
        rangeMap.Add("SpecialObj", new List<Vector2Int>());

        var keyList = rangeMap.Keys.ToList();
        List<Vector2Int> orderList = new List<Vector2Int>();

        for (int i=0;i<lines.Length;i++)
        {
            string line = lines[i];
            line = NiceLine(line);

            bool bDone = false;
            foreach(var key in keyList)
            {
                if (line == "//@@@SDFBakerMgr " + key)
                {
                    rangeMap[key].Add(new Vector2Int(i,-1));
                    bDone = true;
                    break;
                }
            }
            if(bDone)
            {
                continue;
            }

            for (int ikey = 0;ikey < keyList.Count;ikey++)
            {
                string key = keyList[ikey];
                for (int i1 = 0; i1 < rangeMap[key].Count; i1++)
                {
                    if (line == "//@@@" && NeedEnd(rangeMap[key][i1]))
                    {
                        var tt = rangeMap[key][i1];
                        tt.y = i;
                        rangeMap[key][i1] = tt;
                        orderList.Add(new Vector2Int(ikey, i1));
                        break;
                    }
                }
            }
        }

        List<string> newLines = new List<string>(lines);
        int offset = 0;

        for(int i=0;i<orderList.Count;i++)
        {
            var order = orderList[i];
            string key = keyList[order.x];
            var range = rangeMap[key][order.y];
            int oricount = 0, newcount = 0;

            if (key == "ObjSDF" && ValidRange(range))
            {
                oricount = range.y - range.x - 1;
                //删去(range.x,range.y)，插入 bakerMgr.bakedLines
                newcount = bakerMgr.bakedSDFs.Count;
                newLines.RemoveRange(offset + range.x + 1, oricount);
                newLines.InsertRange(offset + range.x + 1, bakerMgr.bakedSDFs);
            }
            else if (key == "SpecialObj" && ValidRange(range))
            {
                oricount = range.y - range.x - 1;
                //删去(range.x,range.y)，插入 bakerMgr.bakedxxx
                newcount = bakerMgr.bakedSpecialObjects.Count;
                newLines.RemoveRange(offset + range.x + 1, oricount);
                newLines.InsertRange(offset + range.x + 1, bakerMgr.bakedSpecialObjects);
            }
            else if (key == "ObjMaterial" && ValidRange(range))
            {
                oricount = range.y - range.x - 1;
                //删去(range.x,range.y)，插入 bakerMgr.bakedxxx
                newcount = bakerMgr.bakedMaterials.Count;
                newLines.RemoveRange(offset + range.x + 1, oricount);
                newLines.InsertRange(offset + range.x + 1, bakerMgr.bakedMaterials);
            }
            else if (key == "ObjRenderMode" && ValidRange(range))
            {
                oricount = range.y - range.x - 1;
                //删去(range.x,range.y)，插入 bakerMgr.bakedxxx
                newcount = bakerMgr.bakedRenderModes.Count;
                newLines.RemoveRange(offset + range.x + 1, oricount);
                newLines.InsertRange(offset + range.x + 1, bakerMgr.bakedRenderModes);
            }
            else if (key == "ObjRender" && ValidRange(range))
            {
                oricount = range.y - range.x - 1;
                //删去(range.x,range.y)，插入 bakerMgr.bakedxxx
                newcount = bakerMgr.bakedRenders.Count;
                newLines.RemoveRange(offset + range.x + 1, oricount);
                newLines.InsertRange(offset + range.x + 1, bakerMgr.bakedRenders);
            }
            else if (key == "DirShadow" && ValidRange(range))
            {
                oricount = range.y - range.x - 1;
                //删去(range.x,range.y)，插入 bakerMgr.bakedxxx
                newcount = bakerMgr.bakedDirShadows.Count;
                newLines.RemoveRange(offset + range.x + 1, oricount);
                newLines.InsertRange(offset + range.x + 1, bakerMgr.bakedDirShadows);
            }
            else if (key == "ValMaps" && ValidRange(range))
            {
                oricount = range.y - range.x - 1;
                newcount = 1;
                newLines.RemoveRange(offset + range.x + 1, oricount);
                string[] newlines = new string[1];
                newlines[0] = "ObjNum " + bakerMgr.tags.Length;
                newLines.InsertRange(offset + range.x + 1, newlines);

            }

            offset += newcount - oricount;
        }
        File.WriteAllLines(path, newLines);
    }

    bool NeedEnd(Vector2Int range)
    {
        return range.x >= 0 && range.y == -1;
    }

    bool ValidRange(Vector2Int range)
    {
        return range.x >= 0 && range.y >= range.x;
    }

    void ClearMemory()
    {
        bakerMgr.ClearMemory();
    }
}

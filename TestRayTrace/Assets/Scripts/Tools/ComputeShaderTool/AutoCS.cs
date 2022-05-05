using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System;
using System.IO;
using System.Linq;
using UnityEngine;
using static StringTool.StringHelper;
using Debug = UnityEngine.Debug;

//[ExecuteInEditMode]
public class AutoCS : MonoBehaviour
{
    public SDFBakerMgr bakerMgr = null;
    public List<string> templates = new List<string>();
    public List<string> outs = new List<string>();
    public List<string> cfgs = new List<string>();

    public string taskFile;

    //??? test public
    public string[] lines;
    public string[] words;
    public Dictionary<string, Vector2Int> rangeMap = new Dictionary<string, Vector2Int>();
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
        string path = FullPath(taskFile);
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
            myProcess.StartInfo.Arguments = FullPath(taskFile);
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
        lines = File.ReadAllLines(path);

        rangeMap.Clear();
        //!!! 顺序必须对应cgf
        rangeMap.Add("ValMaps", new Vector2Int(-1, -1));
        rangeMap.Add("ObjMaterial", new Vector2Int(-1, -1));
        rangeMap.Add("ObjRenderMode", new Vector2Int(-1, -1));
        rangeMap.Add("ObjRender", new Vector2Int(-1, -1));
        rangeMap.Add("ObjSDF", new Vector2Int(-1, -1));

        for (int i=0;i<lines.Length;i++)
        {
            string line = lines[i];
            line = NiceLine(line);

            bool bDone = false;
            foreach(var key in rangeMap.Keys.ToList())
            {
                if (line == "//@@@SDFBakerMgr " + key)
                {
                    rangeMap[key] = new Vector2Int(i,-1);
                    bDone = true;
                    break;
                }
            }
            if(bDone)
            {
                continue;
            }

            foreach (var key in rangeMap.Keys.ToList())
            {
                if (line == "//@@@" && NeedEnd(rangeMap[key]))
                {
                    var tt = rangeMap[key];
                    tt.y = i;
                    rangeMap[key] = tt;
                    //bDone = true;
                    break;
                }
            }
            //if (bDone)
            //{
            //    continue;
            //}
        }

        List<string> newLines = new List<string>(lines);
        int offset = 0;

        //!!! 顺序必须对应cgf
        foreach (var iter in rangeMap)
        {
            //Debug.Log(offset);
            //Debug.Log(iter.Key + " " + iter.Value);
            int oricount = 0, newcount = 0;

            if (iter.Key == "ObjSDF" && ValidRange(iter.Value))
            {
                oricount = iter.Value.y - iter.Value.x - 1;
                //删去(range.x,range.y)，插入 bakerMgr.bakedLines
                newcount = bakerMgr.bakedSDFs.Count;
                newLines.RemoveRange(offset + iter.Value.x + 1, oricount);
                newLines.InsertRange(offset + iter.Value.x + 1, bakerMgr.bakedSDFs);
            }
            else if (iter.Key == "ObjMaterial" && ValidRange(iter.Value))
            {
                oricount = iter.Value.y - iter.Value.x - 1;
                //删去(range.x,range.y)，插入 bakerMgr.bakedxxx
                newcount = bakerMgr.bakedMaterials.Count;
                newLines.RemoveRange(offset + iter.Value.x + 1, oricount);
                newLines.InsertRange(offset + iter.Value.x + 1, bakerMgr.bakedMaterials);
            }
            else if (iter.Key == "ObjRenderMode" && ValidRange(iter.Value))
            {
                oricount = iter.Value.y - iter.Value.x - 1;
                //删去(range.x,range.y)，插入 bakerMgr.bakedxxx
                newcount = bakerMgr.bakedRenderModes.Count;
                newLines.RemoveRange(offset + iter.Value.x + 1, oricount);
                newLines.InsertRange(offset + iter.Value.x + 1, bakerMgr.bakedRenderModes);
            }
            else if (iter.Key == "ObjRender" && ValidRange(iter.Value))
            {
                oricount = iter.Value.y - iter.Value.x - 1;
                //删去(range.x,range.y)，插入 bakerMgr.bakedxxx
                newcount = bakerMgr.bakedRenders.Count;
                newLines.RemoveRange(offset + iter.Value.x + 1, oricount);
                newLines.InsertRange(offset + iter.Value.x + 1, bakerMgr.bakedRenders);
            }
            else if (iter.Key == "ValMaps" && ValidRange(iter.Value))
            {
                oricount = iter.Value.y - iter.Value.x - 1;
                newcount = 1;
                newLines.RemoveRange(offset + iter.Value.x + 1, oricount);
                string[] newlines = new string[1];
                newlines[0] = "ObjNum " + bakerMgr.tags.Length;
                newLines.InsertRange(offset + iter.Value.x + 1, newlines);

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
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TimeLogger
{
    public TimeLogger(string funcName_ = "", bool active_ = true)
    {
        funcName = funcName_;
        active = active_;
    }

    public void Start()
    {
        startTime = Time.realtimeSinceStartup;
    }

    public void Log()
    {
        if (active)
        {
            Debug.Log(funcName + " Part" + part + " " + ((Time.realtimeSinceStartup - startTime) * 1000f) + "ms");
            startTime = Time.realtimeSinceStartup;
            part++;
        }
    }

    public void LogSec()
    {
        if (active)
        {
            Debug.Log(funcName + " Part" + part + " " + ((Time.realtimeSinceStartup - startTime)) + "s");
            startTime = Time.realtimeSinceStartup;
            part++;
        }
    }

    public float GetSec()
    {
        float re = (Time.realtimeSinceStartup - startTime);
        startTime = Time.realtimeSinceStartup;
        part++;
        if (part == 10000)//防止溢出，应该不会用到part那么多，但GetFPS会。
        {
            part = 0;
        }
        return re;
    }

    public float GetMSec()
    {
        return GetSec() * 1000;
    }

    public float GetFPS()
    {
        return 1.0f / GetSec();
    }

    float startTime;
    int part = 1;
    string funcName = "";
    bool active = true;
}

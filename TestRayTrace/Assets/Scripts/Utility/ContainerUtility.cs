using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace XUtility
{
    public class LinesReplaceHelper
    {
        public int offset = 0;
        public int oricount = 0;
        public int newcount = 0;
        public List<string> lines;
        public void Init(in string[] oriLines)
        {
            offset = 0;
            lines = new List<string>(oriLines);
        }

        public void BeginReplaceRange()
        {
            oricount = 0;
            newcount = 0;
        }

        public void EndReplaceRange()
        {
            offset += newcount - oricount;
        }

        public void Replace(Vector2Int range,  in List<string> newLines)
        {
            oricount = range.y - range.x - 1;
            newcount = newLines.Count;
            lines.RemoveRange(offset + range.x + 1, oricount);
            lines.InsertRange(offset + range.x + 1, newLines);
        }

        public void Replace(Vector2Int range, in string newLine)
        {
            oricount = range.y - range.x - 1;
            newcount = 1;
            lines.RemoveRange(offset + range.x + 1, oricount);
            lines.Insert(offset + range.x + 1, newLine);
        }

        public void ClearRange(Vector2Int range)
        {
            oricount = range.y - range.x - 1;
            newcount = 0;
            lines.RemoveRange(offset + range.x + 1, oricount);
        }
    }
}

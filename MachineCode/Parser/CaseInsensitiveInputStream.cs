/*
 * [The "BSD license"]
 *  Copyright (c) 2012 Terence Parr
 *  Copyright (c) 2012 Sam Harwell
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 *  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */



/**
 *
 * @author Sam Harwell
 */

/* Note
 * This code was originally in Java
 */


using System;
using Antlr4.Runtime;

namespace MachineCode.Parser;

/// <summary>
/// Allows reading source files in ANTLR without caring about the case
/// </summary>
public class CaseInsensitiveInputStream : AntlrInputStream
{

    protected char[] lookaheadData;
    protected string _sourceName;

    public CaseInsensitiveInputStream(String input, string sourceName)
        : base(input)
    {
        lookaheadData = input.ToUpper().ToCharArray();
        _sourceName = sourceName;
    }

    public override string SourceName => _sourceName;

    public override int LA(int i)
    {
        if (i == 0)
        {
            return 0; // undefined
        }
        if (i < 0)
        {
            i++; // e.g., translate LA(-1) to use offset i=0; then data[p+0-1]
            if ((p + i - 1) < 0)
            {
                return IntStreamConstants.EOF; // invalid; no char before first char
            }
        }

        if ((p + i - 1) >= n)
        {
            return IntStreamConstants.EOF;
        }

        return lookaheadData[p + i - 1];
    }

}
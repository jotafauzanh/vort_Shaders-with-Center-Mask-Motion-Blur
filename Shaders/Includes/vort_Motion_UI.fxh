/*******************************************************************************
    Author: Vortigern

    License: MIT, Copyright (c) 2023 Vortigern

    MIT License

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
    THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.
*******************************************************************************/

#pragma once
#include "Includes/vort_Defs.fxh"
#include "Includes/vort_Depth.fxh"

/*******************************************************************************
    Globals
*******************************************************************************/

#ifndef V_MV_MODE
    #define V_MV_MODE 1
#endif

#ifndef V_MV_USE_REST
    #define V_MV_USE_REST 0
#endif

#if V_MV_USE_REST == 2
    uniform float4x4 matInvViewProj < source = "mat_InvViewProj"; >;
    uniform float4x4 matPrevViewProj < source = "mat_PrevViewProj"; >;
#endif

#ifndef V_ENABLE_MOT_BLUR
    #define V_ENABLE_MOT_BLUR 0
#endif

#if V_ENABLE_MOT_BLUR
    #ifndef V_MOT_BLUR_USE_COMPUTE
        #define V_MOT_BLUR_USE_COMPUTE 0
    #endif
#endif

#ifndef V_ENABLE_TAA
    #define V_ENABLE_TAA 0
#endif

#define CAT_MOT "Motion Effects"

#if V_ENABLE_MOT_BLUR
    UI_BOOL(CAT_MOT, UI_MB_Debug, "Debug Motion Blur", "", false)
    UI_INT2(CAT_MOT, UI_MB_DebugLen, "Debug Motion Blur Length", "", 0, 100, 0)
    UI_FLOAT(CAT_MOT, UI_MB_Length, "Motion Blur Length", "Controls the amount of blur.", 0.0, 2.0, 1.0)
#endif

#if V_ENABLE_TAA
    UI_FLOAT(CAT_MOT, UI_TAA_Jitter, "TAA Jitter Amount", "How much to shift every pixel position each frame", 0.0, 1.0, 0.0)
    UI_FLOAT(CAT_MOT, UI_TAA_Alpha, "TAA Frame Blend", "Higher values reduce blur, but reduce AA as well", 0.05, 1.0, 0.333)
#endif

UI_HELP(
_vort_MotionEffects_Help_,
"V_MV_MODE - [0 - 3]\n"
"0 - don't calculate motion vectors\n"
"1 - auto include my motion vectors (highly recommended)\n"
"2 - manually use iMMERSE motion vectors\n"
"3 - manually use other motion vectors (qUINT_of, qUINT_motionvectors, DRME, etc.)\n"
"\n"
"V_MV_USE_REST - [0 - 3]\n"
"0 - don't use REST addon for access to game's velocity\n"
"1 - use REST addon to get game's velocity\n"
"2 - use REST addon to get game's velocity in Unreal Engine games\n"
"3 - use REST addon to get only dynamic objects' velocity in Unreal Engine games\n"
"\n"
"V_ENABLE_MOT_BLUR - 0 or 1\n"
"Toggle Motion Blur off or on\n"
"Set to 9 to debug motion vectors\n"
"\n"
"V_MOT_BLUR_USE_COMPUTE - 0 or 1\n"
"Toggle use of compute shaders for Motion Blur\n"
"Can improve performance on newer graphic cards\n"
"\n"
"V_ENABLE_TAA - 0 or 1\n"
"Toggle TAA off or on\n"
"Set to 9 to debug motion vectors\n"
"\n"
"V_HAS_DEPTH - 0 or 1\n"
"Whether the game has depth (2D or 3D)\n"
"\n"
"V_USE_HW_LIN - 0 or 1\n"
"Toggle hardware linearization (better performance).\n"
"Disable if you have color issues due to some bug (like older REST versions).\n"
)

/*******************************************************************************
    Textures, Samplers
*******************************************************************************/

#if V_MV_MODE == 1
    texture2D MotVectTexVort { TEX_SIZE(0) TEX_RG16 };
    sampler2D sMotVectTexVort { Texture = MotVectTexVort; SAM_POINT };

    #define MV_TEX MotVectTexVort
    #define MV_SAMP sMotVectTexVort
#elif V_MV_MODE == 2
    namespace Deferred {
        texture MotionVectorsTex { TEX_SIZE(0) TEX_RG16 };
        sampler sMotionVectorsTex { Texture = MotionVectorsTex; SAM_POINT };
    }

    #define MV_TEX Deferred::MotionVectorsTex
    #define MV_SAMP Deferred::sMotionVectorsTex
#elif V_MV_MODE == 3
    texture2D texMotionVectors { TEX_SIZE(0) TEX_RG16 };
    sampler2D sMotionVectorTex { Texture = texMotionVectors; SAM_POINT };

    #define MV_TEX texMotionVectors
    #define MV_SAMP sMotionVectorTex
#endif

#if V_MV_USE_REST > 0
    texture2D RESTMVTexVort : VELOCITY;
    sampler2D sRESTMVTexVort { Texture = RESTMVTexVort; SAM_POINT };
#endif

/*******************************************************************************
    Functions
*******************************************************************************/

#if V_MV_USE_REST > 0
float2 DecodeVelocity(float2 alt_motion, float2 uv)
{
    float2 v = Sample(sRESTMVTexVort, uv).xy;

// Unreal Engine games
#if V_MV_USE_REST > 1
    // whether there is velocity stored because the object is dynamic
    // or we have to compute static velocity
    if(v.x > 0.0)
    {
        // uncomment if velocity is stored as uint
        /* v /= 65535.0; */

        static const float inv_div = 1.0 / (0.499 * 0.5);
        static const float h = 32767.0 / 65535.0;

        v = (v - h) * inv_div;

        // uncoment if gamma was encoded
        /* v = (v * abs(v)) * 0.5; */

        // normalize
        v *= float2(-0.5, 0.5);
    }
    else
    {
    #if V_MV_USE_REST == 2
        float depth = GetLinearizedDepth(uv);
        float2 curr_screen = (uv * 2.0 - 1.0) * float2(1, -1);
        float4 curr_clip = float4(curr_screen, depth, 1);

    // maybe switch ?
        /* float4 r = mul(matInvViewProj, curr_clip); */
        /* r.xyz *= RCP(r.w); */
        /* float4 curr_pos = float4(r.xyz, 1); */
        /* float4 prev_clip = mul(matPrevViewProj, curr_pos); */
    // alternative
        float4x4 mat_clip_to_prev_clip = mul(matInvViewProj, matPrevViewProj);
        float4 prev_clip = mul(curr_clip, mat_clip_to_prev_clip);
    // end

        float2 prev_screen = prev_clip.xy * RCP(prev_clip.w);

        v = curr_screen - prev_screen;

        // normalize
        v *= float2(-0.5, 0.5);
    #else
        // finding game's matrices is annoying, instead just use the calculated
        // motion vectors for static objects
        v = alt_motion;
    #endif
    }

    return v;
#else
    return v * float2(-0.5, 0.5);
#endif
}
#endif

float2 SampleMotion(float2 uv)
{
    float2 motion = 0;

#ifdef MV_SAMP
    motion = Sample(MV_SAMP, uv).xy;
#endif

#if V_MV_USE_REST > 0
    motion = DecodeVelocity(motion, uv);
#endif

    return motion;
}

float3 DebugMotion(float2 motion)
{
    float angle = atan2(motion.y, motion.x);
    float3 rgb = saturate(3.0 * abs(2.0 * frac(angle / DOUBLE_PI + float3(0.0, -A_THIRD, A_THIRD)) - 1.0) - 1.0);

    return lerp(0.5, rgb, saturate(length(motion) * 100));
}


function [v]=tanks_dyna(tv1,v0)

global u %control actions (column vector \mathbb{R}^n)
global d %disturbances (column vector \mathbb{R}^n)
global K %output constants (column vector \mathbb{R}^n)
global A %matrix for case study

v = 60*(d + A*(v0.*u.*K));
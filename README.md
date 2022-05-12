# 序列式光學模擬系統 (Sequencial Optical System Simulation)

## 前言

這個整套系統是提供給光學透鏡模擬有興趣的朋友所寫的，希望你們用的愉快 : )。同時，我希望將這個系統可以更加完善，若在使用的過程成中，發現有誤或是更好的算法，都歡迎大家一起開發此系統。

這個系統無法像付費軟體 (CODE V 或 Zemax 等) 一樣，進行非常多功能強大的運算，內部只有最基礎的模擬功能，而功能會在之後介紹欄中各個說明。我做這個 Project 是將我在大學與研究所所學的一些光學基礎進行實踐。同時，畢業之後沒有商業軟體可以使用的情況下，自己若想玩一些小設計，勢必要自己開發一套模擬系統，基於此動機就一頭栽進去了哈哈。在開發的過程中，進行了一些 Research，發現有人也有寫光學透鏡的模擬並上傳到 Github，但原始碼非常複雜，因為大量使用 class 使程式碼難以剖析。因此，我在開發時，也盡可能減少 class 的使用，並且以 CODE V 序列式輸入光學透鏡參數的方法，方便大家進行使用，但目前還沒有做成 UI 介面，之後有時間我會再補上 : )。

---

## 介紹

此系統全部都使用 Matlab 環境開發，裡面會用到 Parallel Computing Toolbox 進行平行運算，來加速部分功能的計算效率。內部的功能包含 :

1. 光線追跡 (Ray Tracing)
2. 近軸影像解 (Paraxial Image Solve)
3. 光程差分布 (Optical Path Difference)
4. 線擴散函數 (Line Spread Function)
5. 點擴散函數 (Point Spread Function)
6. 調製傳遞函數 (Modulation Transfer Function, MTF)

(其中，功能 4 ~ 6 有使用到 Parallel Computing Toolbox。)

而下面我會各個介紹整體我計算的方法與功能。在此我先建立一個透鏡來做範例 : 

* Wavelength : 546.1 nm
* Object distance : infinity
* Image distance : 0.15 mm
* Lens type : Plano-Convex Lens
* Lens radius : infinity, -0.1 mm
* Lens thickness : 0.02 mm
* Material : SK16-SCHOTT (n = 1.62286)
* Entrance pupil diameter : 0.05 mm

![image]()

### 1. 光線追跡 (Ray Tracing)

這是透鏡模擬最基本的功能，光線在入射到不同介質時，跟據司乃耳定理 (Snell's Law)，光線的入射的方向向量與入射介面的法向量夾角，稱為入射角 ${\theta_i}$，會受到折射率變化，在出射介面的出射角 ${\theta_t}$ 產生偏折，關係式如下 : 



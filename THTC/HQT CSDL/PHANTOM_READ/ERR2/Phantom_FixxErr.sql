﻿USE DATHANGONLINE
GO

--TÌM KIẾM ĐƠN HÀNG THEO KHU VỰC (TÀI XẾ)
CREATE OR ALTER
PROC USP_TX_SEARCH_DH
--@MA_TX CHAR(8)
AS
SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN
	BEGIN TRY
		DECLARE @TEN_KV NVARCHAR(30)
		SELECT @TEN_KV = (SELECT KV.TEN_KV
							FROM TAI_KHOAN TK JOIN TAI_XE TX ON TK.MA_TK = TX.MA_TK 
									JOIN HOAT_DONG HD ON TX.MA_TX = HD.MA_TX 
									JOIN KHU_VUC_HOAT_DONG KV ON HD.MA_KV = KV.MA_KV
							WHERE TK.TEN_TK = CURRENT_USER)--'tktaixe1')

		SELECT COUNT(*)
		FROM DON_HANG DH
		WHERE DH.THANH_PHO LIKE + '%' + @TEN_KV + '%'

		WAITFOR DELAY '0:0:05'

		SELECT *
		FROM DON_HANG DH
		WHERE DH.THANH_PHO = @TEN_KV

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		RAISERROR(@ErrorMessage,16,1)
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO

--THÊM ĐƠN HÀNG MỚI (KHÁCH HÀNG)
CREATE OR ALTER
PROC USP_THEM_DH
@MA_DH CHAR(8), @THANH_PHO NVARCHAR(30)
AS
BEGIN TRAN
	IF @MA_DH IN (SELECT DH.MA_DH 
					FROM DON_HANG DH)
	BEGIN 
		PRINT @MA_DH + N'ĐÃ TỒN TẠI'
		RETURN
	END

	EXEC USP_KH_TAO_DH @MA_DH, @THANH_PHO

	SELECT DH.*
	FROM DON_HANG DH

COMMIT TRAN
GO
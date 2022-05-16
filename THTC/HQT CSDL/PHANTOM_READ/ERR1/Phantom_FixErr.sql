﻿USE DATHANGONLINE
GO

--TÌM KIẾM SẢN PHẨM THEO DANH MỤC HÀNG HÓA
CREATE OR ALTER 
PROC USP_SEARCH_SP_HH
@TEN_LH NVARCHAR(20)
AS
SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN
	BEGIN TRY
		SELECT COUNT(*)
		FROM LOAI_HANG_HOA LH JOIN SAN_PHAM SP ON LH.MA_LH = SP.MA_LH
		WHERE LH.TEN_LH = @TEN_LH

		WAITFOR DELAY '0:0:05'

		SELECT SP.*
		FROM LOAI_HANG_HOA LH JOIN SAN_PHAM SP ON LH.MA_LH = SP.MA_LH
		WHERE LH.TEN_LH = @TEN_LH
	END TRY
	BEGIN CATCH
		PRINT N'Lỗi hệ thống ' + ERROR_MESSAGE()
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0
GO

--THÊM SẢN PHẨM
CREATE OR ALTER
PROC USP_INSERT_SP_LH
@MA_SP CHAR(8), @MA_LH CHAR(8), @TEN_SP NVARCHAR(50), @MO_TA NTEXT, @MA_CN CHAR(8), @SlUONG INT, @GIA MONEY
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT *
					FROM LOAI_HANG_HOA)
		BEGIN 
			PRINT @MA_LH + N' không tồn tại'
			ROLLBACK TRAN
		END
		EXEC USP_INSERT_SP @MA_SP, @MA_LH, @TEN_SP, @MO_TA, @MA_CN, @SlUONG, @GIA
	END TRY
	BEGIN CATCH
		PRINT N'Lỗi hệ thống ' + ERROR_MESSAGE()
		ROLLBACK TRAN
		RETURN 1	
	END CATCH

COMMIT TRAN
RETURN 0
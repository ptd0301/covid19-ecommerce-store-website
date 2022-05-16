﻿USE DATHANGONLINE
GO
-- CẬP NHẬT SỐ LƯỢNG TỒN KHO
CREATE OR ALTER
PROC USP_SOLUONG_TONKHO
@MA_CN CHAR(8), @MA_SP CHAR(8), @SLUONG INT
AS
BEGIN TRAN
	BEGIN TRY
		SELECT PP.MA_CN, PP.MA_SP, PP.SO_LUONG_TON_KHO
		FROM PHAN_PHOI PP
		WHERE PP.MA_CN = @MA_CN AND PP.MA_SP = @MA_SP

		WAITFOR DELAY '0:0:5'

		IF @MA_CN NOT IN (SELECT CN.MA_CN
						FROM CHI_NHANH CN) --CV_QUANLY_CN
		BEGIN
			PRINT @MA_CN + N' KHÔNG TỒN TẠI'
			ROLLBACK TRAN
		END

		IF @MA_SP NOT IN (SELECT PP.MA_SP
							FROM PHAN_PHOI PP
							WHERE PP.MA_CN = @MA_CN)
		BEGIN
			PRINT @MA_CN + N' KHÔNG PHÂN PHỐI SẢN PHẨM CÓ MÃ ' + @MA_SP
			ROLLBACK TRAN
		END

		UPDATE PHAN_PHOI
		SET PHAN_PHOI.SO_LUONG_TON_KHO = @SLUONG
		WHERE PHAN_PHOI.MA_CN = @MA_CN AND PHAN_PHOI.MA_SP = @MA_SP

		SELECT PP.MA_CN, PP.MA_SP, PP.SO_LUONG_TON_KHO AS SO_LUONG_CAP_NHAT
		FROM PHAN_PHOI PP
		WHERE PP.MA_CN = @MA_CN AND PP.MA_SP = @MA_SP

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		RAISERROR(@ErrorMessage,16,1)
		ROLLBACK TRAN
	END CATCH
	
COMMIT TRAN
GO

--KHÁCH HÀNG MUA SẢN PHẨM (SỐ LƯỢNG TỒN GIẢM)
CREATE OR ALTER
PROC USP_MUA_SP
@MA_DH CHAR(8), @MA_CN CHAR(8), @MA_SP CHAR(8), @SLUONG INT
AS
BEGIN TRAN
	BEGIN TRY
		SELECT PP.MA_CN, PP.MA_SP, PP.SO_LUONG_TON_KHO
		FROM PHAN_PHOI PP
		WHERE PP.MA_CN = @MA_CN AND PP.MA_SP = @MA_SP

		/*IF @MA_SP NOT IN (SELECT PP.MA_SP
						FROM PHAN_PHOI PP
						WHERE PP.MA_CN = @MA_CN)
		BEGIN
			PRINT @MA_SP + N' KHÔNG CÓ TRONG ' + @MA_CN
			PRINT N'BẠN CẦN TẠO 1 ĐƠN HÀNG MỚI'
			ROLLBACK TRAN
		END*/ --chi nhánh A không phân phối sản phẩm X --> tạo đơn mới

		IF @SLUONG > (SELECT PP.SO_LUONG_TON_KHO
						FROM PHAN_PHOI PP
						WHERE PP.MA_CN = @MA_CN AND PP.MA_SP = @MA_SP)
		BEGIN 
			PRINT N'NHÀ PHÂN PHỐI KHÔNG ĐỦ SỐ LƯỢNG CUNG CẤP'
			ROLLBACK TRAN
		END

		DECLARE @THANH_TIEN MONEY
		SELECT @THANH_TIEN = (SELECT PP.GIA * @SLUONG
								FROM PHAN_PHOI PP JOIN DON_HANG DH ON PP.MA_CN = DH.MA_CN
								WHERE PP.MA_SP = @MA_SP AND DH.MA_DH = @MA_DH)
		INSERT DON_HANG(MA_DH, MA_KH, MA_TX, MA_CN, 
					MA_DT, THANH_PHO, DIA_CHI_GH, PHI_SP, PHI_GIAM, PHI_GH, PHI_TONG, TRANG_THAI, HINH_THUC_THANH_TOAN)
		VALUES (@MA_DH, NULL, NULL, @MA_CN, NULL, NULL, NULL, @THANH_TIEN, 0, 0, 0, NULL, NULL)

		INSERT CHI_TIET_DH(MA_DH, MA_SP, SO_LUONG, THANH_TIEN) VALUES (@MA_DH, @MA_SP, @SLUONG, @THANH_TIEN)

		WAITFOR DELAY '0:0:5'
		
		UPDATE PHAN_PHOI
		SET PHAN_PHOI.SO_LUONG_TON_KHO -= @SLUONG
		WHERE PHAN_PHOI.MA_CN = @MA_CN AND PHAN_PHOI.MA_SP = @MA_SP

		SELECT PP.MA_CN, PP.MA_SP, PP.SO_LUONG_TON_KHO
		FROM PHAN_PHOI PP
		WHERE PP.MA_CN = @MA_CN AND PP.MA_SP = @MA_SP
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		RAISERROR(@ErrorMessage,16,1)
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
RETURN 0
GO
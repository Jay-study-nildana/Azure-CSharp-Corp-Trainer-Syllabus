# Appendix 

Some additional notes for students reference

## Essential Short Cuts (VS Code with MS SQL Extension)

1. Ctrl + Shift + E : executes entire file or selected code block in Visual Studio Code. 
1. Ctrl + / : comment selected code.

## Look at Table design

1. sp_help 'One.Students'
    1. look at entire table with all its properties and constraints and all that. 
1. EXEC sp_helpconstraint 'One.Students';
    1. see only the table constraints
1. EXEC sp_helpindex 'One.Students';
    1. see indexes built to this table.
1. You can also look at table design manually by inspected the tables on the left side, but, command line things are better and more future proof and faster.

## Error Handling Pattern

```sql


CREATE PROCEDURE dbo.usp_TemplateWithErrorHandling
    @Param1 INT,
    @Param2 NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;  -- auto-rollback on any error

    -- Validate inputs
    IF @Param1 IS NULL OR @Param2 IS NULL
    BEGIN
        THROW 50001, 'Parameters cannot be NULL.', 1;
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ==================
        -- Business logic here
        -- ==================

        -- Step 1: ...
        -- Step 2: ...
        -- Step 3: ...

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback if a transaction is still open
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Capture error details
        DECLARE @ErrorMsg   NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorNum   INT            = ERROR_NUMBER();
        DECLARE @ErrorSev   INT            = ERROR_SEVERITY();
        DECLARE @ErrorState INT            = ERROR_STATE();
        DECLARE @ErrorLine  INT            = ERROR_LINE();
        DECLARE @ErrorProc  NVARCHAR(200)  = ERROR_PROCEDURE();

        -- Log the error
        INSERT INTO dbo.AuditLog (TableName, Operation, NewValues)
        VALUES (
            N'System', N'ERROR',
            CONCAT(
                N'Error ', @ErrorNum, N' (Severity ', @ErrorSev, N')',
                N' at line ', @ErrorLine,
                N' in ', ISNULL(@ErrorProc, N'ad-hoc'),
                N': ', @ErrorMsg
            )
        );

        -- Re-throw the original error
        THROW;
    END CATCH;
END;
GO

```

## Good luck

Happy Learning. 
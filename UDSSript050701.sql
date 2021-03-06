USE [master]
GO
/****** Object:  Database [TL_CMS]    Script Date: 2015/5/7 6:55:00 ******/
CREATE DATABASE [TL_CMS]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'TL_CMS', FILENAME = N'D:\MDF\TL_CMS.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'TL_CMS_log', FILENAME = N'D:\MDF\TL_CMS_log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [TL_CMS] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [TL_CMS].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [TL_CMS] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [TL_CMS] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [TL_CMS] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [TL_CMS] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [TL_CMS] SET ARITHABORT OFF 
GO
ALTER DATABASE [TL_CMS] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [TL_CMS] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [TL_CMS] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [TL_CMS] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [TL_CMS] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [TL_CMS] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [TL_CMS] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [TL_CMS] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [TL_CMS] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [TL_CMS] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [TL_CMS] SET  DISABLE_BROKER 
GO
ALTER DATABASE [TL_CMS] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [TL_CMS] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [TL_CMS] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [TL_CMS] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [TL_CMS] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [TL_CMS] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [TL_CMS] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [TL_CMS] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [TL_CMS] SET  MULTI_USER 
GO
ALTER DATABASE [TL_CMS] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [TL_CMS] SET DB_CHAINING OFF 
GO
ALTER DATABASE [TL_CMS] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [TL_CMS] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [TL_CMS]
GO
/****** Object:  StoredProcedure [dbo].[usp_Agent]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_Agent]
	@id  int
as
	begin
		select grantorid, grantorname, begintime, endtime
		from vw_agencylist
		where agentid = @id
		order by endtime desc
	end



GO
/****** Object:  StoredProcedure [dbo].[usp_AgentSign]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[usp_AgentSign]
	@pageIndex int,
	@pageSize int,
	@pageCount int output,
	@Temp_Array varchar(max)
as
	begin
		declare @Temp_Variable varchar(max), @num int
        create table #Temp_Table(Item varchar(max))
        while(LEN(@Temp_Array) > 0)
        begin
            if(CHARINDEX(',',@Temp_Array) = 0)
            begin
                set @Temp_Variable = @Temp_Array
                set @Temp_Array = ''
            end
            else
            begin
                set @Temp_Variable = LEFT(@Temp_Array,CHARINDEX(',',@Temp_Array) - 1)
                set @Temp_Array = RIGHT(@Temp_Array,LEN(@Temp_Array)-LEN(@Temp_Variable)-1)
            end    
			insert into #Temp_Table(Item) values(@Temp_Variable)
        end

		select @num=count(*) from (select * from vw_nextsignlist as t where exists(select 1 from #Temp_Table(nolock) where #Temp_Table.Item=signid)) as a

		set @pageCount=CEILING(@num*1.0/@pageSize)

		select id,formname, employeename, nextname, writetime from(select ROW_NUMBER() OVER (ORDER BY writetime) AS Tid, * from vw_nextsignlist(nolock) as t where exists(select 1 from #Temp_Table(nolock) where #Temp_Table.Item=signid) and state = 2) as a
		where Tid between (@pageIndex-1)*@pageSize+1 and @pageIndex*@pageSize
		order by writetime desc

		drop table #Temp_Table
end


GO
/****** Object:  StoredProcedure [dbo].[usp_AgentStop]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_AgentStop]
	@id int
as
	begin
		update T_agency set endtime = GETDATE()
		where id = @id
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_BaseInfo]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_BaseInfo]
	@id int
as
	begin
	select formname, name, department, position, writetime, state, nextname from vw_baseinfo as t
	where id=@id
end


GO
/****** Object:  StoredProcedure [dbo].[usp_DepartmentList]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_DepartmentList]
as
	begin
		select T_department.id, T_department.name as dname, T_position.pname, T_position.id as pid
		from T_department inner join T_position
		on T_department.directorposid = T_position.id
		order by T_department.id
	end

GO
/****** Object:  StoredProcedure [dbo].[usp_DepartmentSelectorAll]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_DepartmentSelectorAll]
as
	begin
		select id, name
		from T_department
		order by id
	end

GO
/****** Object:  StoredProcedure [dbo].[usp_DepartmentUpdate]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_DepartmentUpdate]
	@id int,
	@pid int,
	@dname nvarchar(50)
as
	begin
		update T_department set name=@dname, directorposid=@pid
		where id=@id
	end

GO
/****** Object:  StoredProcedure [dbo].[usp_DepPosId]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_DepPosId]
	@id int
as
	begin
		select T_department.directorposid
		from T_employee inner join
		T_department on T_employee.departmentid = T_department.id
		where T_employee.id = @id
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeSelectorAll]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_EmployeeSelectorAll]
as
	begin
		select id, name
		from T_employee
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeSelectorOn]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_EmployeeSelectorOn]
as
	begin
		select id, name
		from T_employee
		where isonjob = 1
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeUserGetById]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_EmployeeUserGetById]
	@id int
as
	begin
		select name, pid, did, spid, uid, loginname, userlevel
		from vw_employeeuser
		where id =@id
	end

GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeUserList]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_EmployeeUserList]
as
	begin
		select id, name, pname, dname, isnull(spname, '') as spname, loginname, isonjob
		from vw_employeeuser
		order by isonjob desc, id asc
	end

GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeUserOldModify]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_EmployeeUserOldModify]
	@pid int
as
	begin
		declare @eid int;
		select @eid=T_employee.id 
		from T_employee inner join T_position 
		on T_employee.positionid=T_position.id 
		where T_employee.positionid = @pid
		if @eid <> 0
		begin
		update T_employee set positionid=5, superiorposid=@pid
		where id = @eid
			update T_user set userlevel=3 where eid=@eid
			end
end

GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeUserUpdateCareer]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_EmployeeUserUpdateCareer]
	@id int,
	@onjob int
as
	begin
		update T_employee set isonjob=@onjob where id=@id
		update T_user set isdelete=@onjob where eid=@id
	end

GO
/****** Object:  StoredProcedure [dbo].[usp_EmployeeUserUpdateInfo]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_EmployeeUserUpdateInfo]
	@id int,
	@name nvarchar(10),
	@pid int,
	@did int,
	@spid int,
	@loginname nvarchar(20),
	@userlevel int
as
	begin
		update T_employee 
		set name=@name, positionid=@pid, departmentid=@did, superiorposid=@spid 
		where id=@id
		update T_user 
		set loginname=@loginname, userlevel=@userlevel 
		where eid=@id
	end

GO
/****** Object:  StoredProcedure [dbo].[usp_ExamInfo]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_ExamInfo]
	@id int
as
	begin
		select name, signtime, result, reason 
		from vw_examinfo as t
		where id = @id
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_Grantor]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_Grantor]
	@id  int
as
	begin
		select id, agentname, begintime, endtime
		from vw_agencylist
		where grantorid = @id
		order by endtime desc
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_GrantorIds]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_GrantorIds]
	@id int
as
	begin
		select grantorid
		from vw_agencylist
		where agentid = @id and DATEDIFF(second, begintime, GETDATE()) >= 0 and DATEDIFF(second, GETDATE(), endtime) >= 0
		group by grantorid
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_Login]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_Login]
	@username nvarchar(20)
as
	begin
		select uid,username, password, userlevel,eid, ename, isdelete
		from vw_login as t
		where username=@username
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_NextSign]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_NextSign]
	@pageIndex int,
	@pageSize int,
	@pageCount int output,
	@eid int
as
	begin
		declare @num int
		select @num=count(*) from (select * from vw_nextsignlist as t where signid=@eid) as a

		set @pageCount=CEILING(@num*1.0/@pageSize)

		select id,formname, employeename, writetime from(select ROW_NUMBER() OVER (ORDER BY writetime desc) AS Tid, * from vw_nextsignlist as t where signid=@eid and state = 2) as a
		where Tid between (@pageIndex-1)*@pageSize+1 and @pageIndex*@pageSize
end


GO
/****** Object:  StoredProcedure [dbo].[usp_OwnApply]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_OwnApply]
	@pageIndex int,
	@pageSize int,
	@pageCount int output,
	@eid int
as
	begin
	declare @num int
	select @num=count(*) from (select * from vw_ownwrittenlist as t where eid=@eid and state != '未发送')as a

	set @pageCount=CEILING(@num*1.0/@pageSize)

	select id, formname, writetime, nextname, state 
	from(select ROW_NUMBER() OVER (ORDER BY writetime desc) AS Tid, * 
	from vw_ownwrittenlist as t where eid=@eid and state != '未发送')as a
	where Tid between (@pageIndex-1)*@pageSize+1 and @pageIndex*@pageSize
end


GO
/****** Object:  StoredProcedure [dbo].[usp_OwnDraft]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--我的草稿列表分页存储过程
CREATE proc [dbo].[usp_OwnDraft]
	@pageIndex int,
	@pageSize int,
	@pageCount int output,
	@eid int
as
	begin
		declare @num int
		select @num=count(*) from (select * from vw_ownwrittenlist as t where eid=@eid and state = '未发送')as a
		set @pageCount=CEILING(@num*1.0/@pageSize)

		select id, formname, writetime, state 
		from(select ROW_NUMBER() OVER (ORDER BY writetime desc) AS Tid, * 
		from vw_ownwrittenlist as t where eid=@eid and state = '未发送')as a
		where Tid between (@pageIndex-1)*@pageSize+1 and @pageIndex*@pageSize
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_PosId]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_PosId]
	@id int
as
	begin
		select positionid
		from T_employee
		where id= @id
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_PositionList]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_PositionList]
as
	begin
		select T_position.id, T_position.pname, T_employee.name as ename, T_employee.id as eid
		from T_position inner join T_employee
		on T_position.employeeid = T_employee.id
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_PositionSelectorAll]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_PositionSelectorAll]
as
	begin
	select pname as name, id
	from T_position
	order by id
	end

GO
/****** Object:  StoredProcedure [dbo].[usp_PositionSelectorCharge]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_PositionSelectorCharge]
as
	begin
	select pname as name, id
	from T_position
	where id <> 5
	order by id
	end

GO
/****** Object:  StoredProcedure [dbo].[usp_PositionUpdate]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_PositionUpdate]
	@id int,
	@eid int,
	@pname nvarchar(50)
as
	begin
		update T_position
		set employeeid = @eid, pname = @pname
		where id = @id
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_PreMainInfo]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_PreMainInfo]
	@id int
as
	begin
		select forminnerid, tablename, fieldtable, pagename, formid 
		from vw_premaininfo as t
		where id=@id
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_PreSign]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_PreSign]
	@id int
as
	begin
		select nextstep, signposlist
		from T_formflow
		where id = @id
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_RecordSign]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_RecordSign]
	@pageIndex int,
	@pageSize int,
	@pageCount int output,
	@eid int
as
	begin
		declare @num int
		select @num=count(*) from(select * from vw_recordsignlist as t where eid=@eid)as a

		set @pageCount=CEILING(@num*1.0/@pageSize)

		select id, formname, employeename, writetime, state 
		from(select ROW_NUMBER() OVER (ORDER BY writetime desc) AS Tid, * 
		from vw_recordsignlist as t where eid=@eid)as a
		where Tid between (@pageIndex-1)*@pageSize+1 and @pageIndex*@pageSize
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_Send]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_Send]
	@sendtime datetime,
	@nextid int,
	@id int
as
	begin
		update T_formflow set writetime=@sendtime, nextstep = @nextid, state = 2
		where id = @id
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_SignAgreeInfo]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_SignAgreeInfo]
	@formflowid int,
	@eid int,
	@time datetime,
	@reason nvarchar(100)
as
	begin
		insert into T_option(formflowid, employeeid, signtime, resultid, reason)
		values(@formflowid, @eid, @time, 1, @reason)
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_SignFail]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_SignFail]
	@id int
as
	begin
		update T_formflow set nextstep=0, state=4
		where id = @id
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_SignNext]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_SignNext]
	@id int,
	@nextid int
as
	begin
		update T_formflow set nextstep=@nextid
		where id=@id
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_SignRefuseInfo]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_SignRefuseInfo]
	@formflowid int,
	@eid int,
	@time datetime,
	@reason nvarchar(100)
as
	begin
		insert into T_option(formflowid, employeeid, signtime, resultid, reason)
		values(@formflowid, @eid, @time, 2, @reason)
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_SignSuccess]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[usp_SignSuccess]
	@nextstep int,
	@id int
as
	begin
		update T_formflow set nextstep=@nextstep, state=3
		where id=@id
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_StaJB]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_StaJB]
	@eid int,
	@begintime DateTime,
	@endtime DateTime
as
	begin
		select subname as typename, sum(totaltime) as timesum
		from vw_stajb
		where eid = @eid and begintime > @begintime and endtime < @endtime and typename = '加班结算方式' and formid = 1
		group by subname
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_StaQJ]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_StaQJ]
	@eid int,
	@begintime DateTime,
	@endtime DateTime
as
	begin
		select subname as typename, sum(totaltime) as timesum
		from vw_staqj
		where eid = @eid and begintime > @begintime and endtime < @endtime and typename = '请假类别' and formid = 2
		group by subname
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_SuperEid]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_SuperEid]
	@id int
as
	begin
		select T_position.employeeid
		from T_employee inner join
		T_position on T_employee.superiorposid = T_position.id
		where T_employee.id = @id
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_SuperiorPosId]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_SuperiorPosId]
	@id int
as
	begin
		select superiorposid
		from T_employee
		where id = @id
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_WriteDetail]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_WriteDetail]
	@id int
as
	begin
		select T_template.pagename, T_flow.flow
		from T_flow inner join T_template
		on T_flow.templateid=T_template.id
		where T_flow.id=@id
	end
GO
/****** Object:  StoredProcedure [dbo].[usp_WriteList]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[usp_WriteList]
as
	begin
		select id, formname
		from T_flow
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_WriteModify]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--修改填写的表单，只修改时间
create proc [dbo].[usp_WriteModify]
	@id int,
	@time datetime
as
	begin
		update T_formflow set writetime=@time where id=@id
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_WriteModifySignList]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_WriteModifySignList]
	@id int,
	@time datetime,
	@signlist nvarchar(50)
as
	begin
		update T_formflow set writetime=@time, signposlist=@signlist where id=@id
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_WriteSave]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--保存填写的表单基本信息至总实例表，返回插入的编号
CREATE proc [dbo].[usp_WriteSave]
	@innerid int,
	@formid int,
	@eid int,
	@writetime datetime,
	@signlist varchar(50),
	@id int output
as
	begin
		declare @t table(id int)
		insert into T_formflow(forminnerid, formid, eid, writetime, nextstep, state, signposlist) output inserted.ID into @t
		values(@innerid, @formid, @eid, @writetime, 0, 1, @signlist)
		set @id=(select id from @t)
	end


GO
/****** Object:  StoredProcedure [dbo].[usp_WriteSend]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--发送填写的表单，记录申请时间，下一待签职位编号，待签职位列表
create proc [dbo].[usp_WriteSend]
	@id int,
	@applytime datetime,
	@next int,
	@signlist nvarchar(50)
as
	begin
		update T_formflow set writetime=@applytime, nextstep=@next, state=2, signposlist=@signlist
		where id=@id
	end


GO
/****** Object:  Table [dbo].[T_agency]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_agency](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[grantorid] [int] NOT NULL,
	[agentid] [int] NOT NULL,
	[begintime] [datetime] NOT NULL,
	[endtime] [datetime] NOT NULL,
 CONSTRAINT [PK_T_agency] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_bgwj]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_bgwj](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[details] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_T_bgwj] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_department]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_department](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[directorposid] [int] NOT NULL,
 CONSTRAINT [PK_T_department] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_employee]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_employee](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](10) NOT NULL,
	[positionid] [int] NOT NULL,
	[departmentid] [int] NOT NULL,
	[superiorposid] [int] NOT NULL,
	[isonjob] [bit] NOT NULL,
 CONSTRAINT [PK_T_employee] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_fieldtype]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_fieldtype](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[subname] [nvarchar](20) NOT NULL,
	[typename] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_T_fieldtype] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_flow]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_flow](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[formname] [nvarchar](50) NOT NULL,
	[tablename] [varchar](20) NOT NULL,
	[pagename] [varchar](50) NOT NULL,
	[flow] [varchar](150) NULL,
	[fieldtable] [varchar](20) NULL,
	[templateid] [int] NULL,
 CONSTRAINT [PK_T_flow] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_flowname]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_flowname](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[flowname] [nvarchar](50) NOT NULL,
	[symbol] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_T_flowname] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_formflow]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_formflow](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[formid] [int] NOT NULL,
	[forminnerid] [int] NOT NULL,
	[eid] [int] NOT NULL,
	[writetime] [datetime] NOT NULL,
	[nextstep] [int] NOT NULL,
	[state] [int] NOT NULL,
	[signposlist] [varchar](50) NULL,
 CONSTRAINT [PK_T_formflow] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_fybx]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_fybx](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[usage] [nvarchar](200) NOT NULL,
	[happendate] [date] NOT NULL,
	[money] [decimal](15, 2) NOT NULL,
	[bmoney] [nvarchar](50) NOT NULL,
	[prepay] [decimal](15, 2) NOT NULL,
	[returnpay] [decimal](15, 2) NOT NULL,
	[attachpath] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_T_fybx] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_gc]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_gc](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[begintime] [datetime] NOT NULL,
	[endtime] [datetime] NOT NULL,
	[reason] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_T_gc] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_gdzc]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_gdzc](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[devicename] [nvarchar](30) NOT NULL,
	[count] [int] NOT NULL,
	[description] [nvarchar](200) NOT NULL,
	[singleprice] [decimal](15, 2) NOT NULL,
	[totalprice] [decimal](15, 2) NOT NULL,
	[needdate] [date] NOT NULL,
 CONSTRAINT [PK_T_gdzc] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_hyjl]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_hyjl](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[meetingdate] [date] NOT NULL,
	[topic] [nvarchar](50) NOT NULL,
	[attachcontent] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_T_hyjl] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_jb]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_jb](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[begintime] [datetime] NOT NULL,
	[endtime] [datetime] NOT NULL,
	[totaltime] [float] NOT NULL,
	[reason] [nvarchar](50) NOT NULL,
	[typeid] [int] NOT NULL,
 CONSTRAINT [PK_T_jb] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_log]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_log](
	[id] [uniqueidentifier] NOT NULL,
	[operatorid] [int] NOT NULL,
	[operatetime] [datetime] NOT NULL,
	[description] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_T_log] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_option]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_option](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[formflowid] [int] NOT NULL,
	[employeeid] [int] NOT NULL,
	[signtime] [datetime] NOT NULL,
	[resultid] [int] NOT NULL,
	[reason] [nvarchar](100) NULL,
 CONSTRAINT [PK_T_option] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_position]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_position](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[pname] [nvarchar](50) NOT NULL,
	[employeeid] [int] NOT NULL,
 CONSTRAINT [PK_T_position] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_px]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_px](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[begindate] [date] NOT NULL,
	[enddate] [date] NOT NULL,
	[typeid] [int] NOT NULL,
	[title] [nvarchar](50) NOT NULL,
	[attachcontent] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_T_px] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_qj]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_qj](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[begintime] [datetime] NOT NULL,
	[endtime] [datetime] NOT NULL,
	[totaltime] [float] NOT NULL,
	[reason] [nvarchar](50) NOT NULL,
	[typeid] [int] NOT NULL,
 CONSTRAINT [PK_T_qj] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_qtjl]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_qtjl](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[visitorid] [int] NOT NULL,
	[bevisitor] [nvarchar](20) NOT NULL,
	[property] [nvarchar](50) NOT NULL,
	[begintime] [datetime] NOT NULL,
	[endtime] [datetime] NOT NULL,
	[attachcontent] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_T_qtjl] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_result]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_result](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[description] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_T_result] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_state]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_state](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[statedesc] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_T_state] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_syqmkh]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_syqmkh](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[entrydate] [date] NOT NULL,
	[passdate] [date] NOT NULL,
	[valuation] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_T_syqmkh] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_template]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_template](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[templatename] [nvarchar](50) NOT NULL,
	[tablename] [varchar](50) NOT NULL,
	[pagename] [varchar](50) NOT NULL,
 CONSTRAINT [PK_T_Template] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_user]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_user](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[eid] [int] NULL,
	[loginname] [nvarchar](20) NOT NULL,
	[password] [nvarchar](500) NOT NULL,
	[userlevel] [int] NOT NULL,
	[isdelete] [bit] NOT NULL,
 CONSTRAINT [PK_T_user] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_xzjx]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_xzjx](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[applymonth] [date] NOT NULL,
	[attachcontent] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_T_xzjx] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[T_zz]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_zz](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[money] [decimal](15, 2) NOT NULL,
	[reason] [nvarchar](100) NOT NULL,
	[predate] [date] NOT NULL,
 CONSTRAINT [PK_T_zz] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[vw_agencylist]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_agencylist]
AS
SELECT   e1.name AS grantorname, e2.name AS agentname, dbo.T_agency.begintime, dbo.T_agency.endtime, 
                dbo.T_agency.grantorid, dbo.T_agency.agentid, dbo.T_agency.id
FROM      dbo.T_agency INNER JOIN
                dbo.T_employee AS e1 ON dbo.T_agency.grantorid = e1.id INNER JOIN
                dbo.T_employee AS e2 ON dbo.T_agency.agentid = e2.id



GO
/****** Object:  View [dbo].[vw_baseinfo]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_baseinfo]
AS
SELECT   dbo.T_formflow.id, dbo.T_flow.formname, dbo.T_employee.name, dbo.T_department.name AS department, 
                dbo.T_position.pname AS position, dbo.T_formflow.writetime, dbo.T_state.statedesc AS state, 
                ISNULL(T_employee_1.name, '') AS nextname
FROM      dbo.T_formflow INNER JOIN
                dbo.T_flow ON dbo.T_formflow.formid = dbo.T_flow.id INNER JOIN
                dbo.T_employee ON dbo.T_formflow.eid = dbo.T_employee.id INNER JOIN
                dbo.T_position ON dbo.T_employee.positionid = dbo.T_position.id INNER JOIN
                dbo.T_department ON dbo.T_employee.departmentid = dbo.T_department.id LEFT OUTER JOIN
                dbo.T_position AS T_position_1 ON dbo.T_formflow.nextstep = T_position_1.id LEFT OUTER JOIN
                dbo.T_employee AS T_employee_1 ON T_position_1.employeeid = T_employee_1.id INNER JOIN
                dbo.T_state ON dbo.T_formflow.state = dbo.T_state.id



GO
/****** Object:  View [dbo].[vw_employee]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_employee]
AS
SELECT   dbo.T_user.id, dbo.T_user.loginname, dbo.T_user.password, dbo.T_user.eid, dbo.T_employee.superiorposid, 
                dbo.T_employee.name, dbo.T_department.directorposid, dbo.T_employee.positionid, dbo.T_position.pname
FROM      dbo.T_employee INNER JOIN
                dbo.T_position ON dbo.T_employee.positionid = dbo.T_position.id INNER JOIN
                dbo.T_department ON dbo.T_department.id = dbo.T_employee.departmentid INNER JOIN
                dbo.T_user ON dbo.T_employee.id = dbo.T_user.eid



GO
/****** Object:  View [dbo].[vw_employeeuser]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_employeeuser]
AS
SELECT   dbo.T_employee.id, dbo.T_employee.name, dbo.T_employee.positionid AS pid, dbo.T_position.pname, 
                dbo.T_employee.departmentid AS did, dbo.T_department.name AS dname, dbo.T_employee.superiorposid AS spid, 
                T_position_1.pname AS spname, dbo.T_employee.isonjob, dbo.T_user.loginname, dbo.T_user.userlevel, 
                dbo.T_user.id AS uid
FROM      dbo.T_employee INNER JOIN
                dbo.T_position ON dbo.T_employee.positionid = dbo.T_position.id INNER JOIN
                dbo.T_department ON dbo.T_employee.departmentid = dbo.T_department.id LEFT OUTER JOIN
                dbo.T_position AS T_position_1 ON dbo.T_employee.superiorposid = T_position_1.id INNER JOIN
                dbo.T_user ON dbo.T_employee.id = dbo.T_user.eid


GO
/****** Object:  View [dbo].[vw_examinfo]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_examinfo]
AS
SELECT   TOP (100) PERCENT dbo.T_option.formflowid AS id, dbo.T_employee.name, dbo.T_option.signtime, 
                dbo.T_result.description AS result, ISNULL(dbo.T_option.reason, '') AS reason
FROM      dbo.T_option INNER JOIN
                dbo.T_employee ON dbo.T_option.employeeid = dbo.T_employee.id INNER JOIN
                dbo.T_result ON dbo.T_option.resultid = dbo.T_result.id
ORDER BY dbo.T_option.signtime



GO
/****** Object:  View [dbo].[vw_login]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_login]
AS
SELECT   dbo.T_user.id AS uid, dbo.T_user.loginname AS username, dbo.T_user.password, dbo.T_user.userlevel, 
                ISNULL(dbo.T_user.eid, 0) AS eid, ISNULL(dbo.T_employee.name, '') AS ename, dbo.T_user.isdelete
FROM      dbo.T_user LEFT OUTER JOIN
                dbo.T_employee ON dbo.T_user.eid = dbo.T_employee.id



GO
/****** Object:  View [dbo].[vw_nextsignlist]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_nextsignlist]
AS
SELECT   dbo.T_formflow.id, dbo.T_flow.formname, dbo.T_employee.name AS employeename, dbo.T_formflow.writetime, 
                dbo.T_position.employeeid AS signid, dbo.T_formflow.state, se.name AS nextname
FROM      dbo.T_formflow INNER JOIN
                dbo.T_flow ON dbo.T_formflow.formid = dbo.T_flow.id INNER JOIN
                dbo.T_employee ON dbo.T_employee.id = dbo.T_formflow.eid INNER JOIN
                dbo.T_position ON dbo.T_formflow.nextstep = dbo.T_position.id INNER JOIN
                dbo.T_employee AS se ON dbo.T_position.employeeid = se.id



GO
/****** Object:  View [dbo].[vw_ownwrittenlist]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ownwrittenlist]
AS
SELECT   dbo.T_formflow.id, dbo.T_formflow.eid, dbo.T_flow.formname, dbo.T_formflow.writetime, ISNULL(dbo.T_employee.name, 
                '') AS nextname, dbo.T_state.statedesc AS state
FROM      dbo.T_formflow INNER JOIN
                dbo.T_flow ON dbo.T_formflow.formid = dbo.T_flow.id LEFT OUTER JOIN
                dbo.T_position ON dbo.T_formflow.nextstep = dbo.T_position.id LEFT OUTER JOIN
                dbo.T_employee ON dbo.T_employee.id = dbo.T_position.employeeid INNER JOIN
                dbo.T_state ON dbo.T_formflow.state = dbo.T_state.id



GO
/****** Object:  View [dbo].[vw_premaininfo]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_premaininfo]
AS
SELECT   dbo.T_formflow.id, dbo.T_formflow.forminnerid, dbo.T_flow.tablename, dbo.T_flow.fieldtable, dbo.T_formflow.formid, 
                dbo.T_flow.pagename
FROM      dbo.T_formflow INNER JOIN
                dbo.T_flow ON dbo.T_formflow.formid = dbo.T_flow.id



GO
/****** Object:  View [dbo].[vw_recordsignlist]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_recordsignlist]
AS
SELECT   dbo.T_formflow.id, dbo.T_option.employeeid AS eid, dbo.T_flow.formname, dbo.T_employee.name AS employeename, 
                dbo.T_formflow.writetime, dbo.T_state.statedesc AS state
FROM      dbo.T_formflow INNER JOIN
                dbo.T_flow ON dbo.T_formflow.formid = dbo.T_flow.id INNER JOIN
                dbo.T_employee ON dbo.T_employee.id = dbo.T_formflow.eid INNER JOIN
                dbo.T_state ON dbo.T_formflow.state = dbo.T_state.id INNER JOIN
                dbo.T_option ON dbo.T_formflow.id = dbo.T_option.formflowid



GO
/****** Object:  View [dbo].[vw_stajb]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_stajb]
AS
SELECT   dbo.T_formflow.formid, dbo.T_formflow.eid, dbo.T_jb.begintime, dbo.T_jb.endtime, dbo.T_jb.totaltime, 
                dbo.T_fieldtype.subname, dbo.T_fieldtype.typename
FROM      dbo.T_formflow INNER JOIN
                dbo.T_jb ON dbo.T_formflow.forminnerid = dbo.T_jb.id INNER JOIN
                dbo.T_fieldtype ON dbo.T_jb.typeid = dbo.T_fieldtype.id



GO
/****** Object:  View [dbo].[vw_staqj]    Script Date: 2015/5/7 6:55:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_staqj]
AS
SELECT   dbo.T_formflow.formid, dbo.T_formflow.eid, dbo.T_qj.begintime, dbo.T_qj.endtime, dbo.T_qj.totaltime, 
                dbo.T_fieldtype.subname, dbo.T_fieldtype.typename
FROM      dbo.T_formflow INNER JOIN
                dbo.T_qj ON dbo.T_formflow.forminnerid = dbo.T_qj.id INNER JOIN
                dbo.T_fieldtype ON dbo.T_qj.typeid = dbo.T_fieldtype.id



GO
SET IDENTITY_INSERT [dbo].[T_agency] ON 

INSERT [dbo].[T_agency] ([id], [grantorid], [agentid], [begintime], [endtime]) VALUES (1, 4, 12, CAST(0x0000A48200000000 AS DateTime), CAST(0x0000A47F0188AEF1 AS DateTime))
INSERT [dbo].[T_agency] ([id], [grantorid], [agentid], [begintime], [endtime]) VALUES (2, 4, 12, CAST(0x0000A46D00000000 AS DateTime), CAST(0x0000A57E00000000 AS DateTime))
INSERT [dbo].[T_agency] ([id], [grantorid], [agentid], [begintime], [endtime]) VALUES (3, 4, 12, CAST(0x0000A47F00D8B490 AS DateTime), CAST(0x0000A48200D8B490 AS DateTime))
SET IDENTITY_INSERT [dbo].[T_agency] OFF
SET IDENTITY_INSERT [dbo].[T_bgwj] ON 

INSERT [dbo].[T_bgwj] ([id], [details]) VALUES (1, N'教材费')
INSERT [dbo].[T_bgwj] ([id], [details]) VALUES (2, N'课时费')
INSERT [dbo].[T_bgwj] ([id], [details]) VALUES (3, N'平台信息')
INSERT [dbo].[T_bgwj] ([id], [details]) VALUES (4, N'办公文具')
INSERT [dbo].[T_bgwj] ([id], [details]) VALUES (5, N'<p>213215346534678697088675123<br/></p>')
SET IDENTITY_INSERT [dbo].[T_bgwj] OFF
SET IDENTITY_INSERT [dbo].[T_department] ON 

INSERT [dbo].[T_department] ([id], [name], [directorposid]) VALUES (1, N'教务部', 3)
INSERT [dbo].[T_department] ([id], [name], [directorposid]) VALUES (2, N'人事部', 7)
INSERT [dbo].[T_department] ([id], [name], [directorposid]) VALUES (3, N'财务部', 6)
INSERT [dbo].[T_department] ([id], [name], [directorposid]) VALUES (4, N'招生部', 8)
INSERT [dbo].[T_department] ([id], [name], [directorposid]) VALUES (5, N'天林教育', 1)
INSERT [dbo].[T_department] ([id], [name], [directorposid]) VALUES (6, N'技术部', 9)
INSERT [dbo].[T_department] ([id], [name], [directorposid]) VALUES (7, N'行政部', 10)
SET IDENTITY_INSERT [dbo].[T_department] OFF
SET IDENTITY_INSERT [dbo].[T_employee] ON 

INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (1, N'张天韻', 1, 5, 0, 1)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (2, N'王新睿', 2, 5, 1, 1)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (3, N'汪春霞', 3, 1, 2, 1)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (4, N'王辉', 7, 2, 2, 1)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (5, N'钱培芬', 6, 3, 2, 1)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (6, N'肖霖', 8, 4, 2, 1)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (7, N'孟繁钰', 4, 1, 3, 1)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (8, N'沈俊杰', 5, 1, 3, 1)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (9, N'盛小雪', 5, 1, 3, 1)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (10, N'张莉', 5, 1, 3, 1)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (11, N'蒋梦婷', 5, 1, 3, 1)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (12, N'邱满', 5, 6, 9, 1)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (13, N'孙辉', 5, 6, 9, 0)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (14, N'钟晓君', 5, 1, 3, 1)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (15, N'王赪', 5, 1, 3, 1)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (16, N'陶春松', 5, 4, 8, 1)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (17, N'邹志超', 5, 4, 8, 1)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (18, N'', 1, 3, 0, 1)
INSERT [dbo].[T_employee] ([id], [name], [positionid], [departmentid], [superiorposid], [isonjob]) VALUES (19, N'', 1, 3, 0, 1)
SET IDENTITY_INSERT [dbo].[T_employee] OFF
SET IDENTITY_INSERT [dbo].[T_fieldtype] ON 

INSERT [dbo].[T_fieldtype] ([id], [subname], [typename]) VALUES (1, N'调休', N'请假类别')
INSERT [dbo].[T_fieldtype] ([id], [subname], [typename]) VALUES (2, N'事假', N'请假类别')
INSERT [dbo].[T_fieldtype] ([id], [subname], [typename]) VALUES (3, N'病假', N'请假类别')
INSERT [dbo].[T_fieldtype] ([id], [subname], [typename]) VALUES (4, N'产假', N'请假类别')
INSERT [dbo].[T_fieldtype] ([id], [subname], [typename]) VALUES (5, N'婚假', N'请假类别')
INSERT [dbo].[T_fieldtype] ([id], [subname], [typename]) VALUES (6, N'丧假', N'请假类别')
INSERT [dbo].[T_fieldtype] ([id], [subname], [typename]) VALUES (7, N'其他', N'请假类别')
INSERT [dbo].[T_fieldtype] ([id], [subname], [typename]) VALUES (8, N'调休', N'加班结算方式')
INSERT [dbo].[T_fieldtype] ([id], [subname], [typename]) VALUES (9, N'加班费', N'加班结算方式')
INSERT [dbo].[T_fieldtype] ([id], [subname], [typename]) VALUES (10, N'内训', N'培训类型')
INSERT [dbo].[T_fieldtype] ([id], [subname], [typename]) VALUES (11, N'外训', N'培训类型')
SET IDENTITY_INSERT [dbo].[T_fieldtype] OFF
SET IDENTITY_INSERT [dbo].[T_flow] ON 

INSERT [dbo].[T_flow] ([id], [formname], [tablename], [pagename], [flow], [fieldtable], [templateid]) VALUES (1, N'加班申请流程
', N'T_jb', N'JBInfo', N'T|U|D|7', N'FT_jb', 2)
INSERT [dbo].[T_flow] ([id], [formname], [tablename], [pagename], [flow], [fieldtable], [templateid]) VALUES (2, N'请假申请流程
', N'T_qj
', N'QJInfo', N'T|U|D|2|7', N'FT_qj', 3)
INSERT [dbo].[T_flow] ([id], [formname], [tablename], [pagename], [flow], [fieldtable], [templateid]) VALUES (3, N'公出申请流程
', N'T_gc
', N'GCInfo', N'T|U|D|7', N'FT_gc', 4)
INSERT [dbo].[T_flow] ([id], [formname], [tablename], [pagename], [flow], [fieldtable], [templateid]) VALUES (4, N'费用报销流程
', N'T_fybx
', N'FYBXInfo', N'T|6|2|1|6', N'FT_fybx', 5)
INSERT [dbo].[T_flow] ([id], [formname], [tablename], [pagename], [flow], [fieldtable], [templateid]) VALUES (5, N'会议记录流程
', N'T_hyjl
', N'HYJLInfo', N'T|U|D|7', N'FT_hyjl', 6)
INSERT [dbo].[T_flow] ([id], [formname], [tablename], [pagename], [flow], [fieldtable], [templateid]) VALUES (6, N'办公文具申请流程
', N'T_bgwj
', N'CommonModelInfo', N'T|U|D|7', N'FT_bgwj', 1)
INSERT [dbo].[T_flow] ([id], [formname], [tablename], [pagename], [flow], [fieldtable], [templateid]) VALUES (7, N'试用期满考核流程
', N'T_syqmkh
', N'SYQMKHInfo', N'T|U|D|2|7', N'FT_syqmkh', 7)
INSERT [dbo].[T_flow] ([id], [formname], [tablename], [pagename], [flow], [fieldtable], [templateid]) VALUES (8, N'洽谈记录流程
', N'T_qtjl
', N'QTJLInfo', N'T|U|D|2|7', N'FT_qtjl', 8)
INSERT [dbo].[T_flow] ([id], [formname], [tablename], [pagename], [flow], [fieldtable], [templateid]) VALUES (9, N'薪资绩效申报流程
', N'T_xzjx
', N'XZJXInfo', N'T|1|0', N'FT_xzjx', 9)
INSERT [dbo].[T_flow] ([id], [formname], [tablename], [pagename], [flow], [fieldtable], [templateid]) VALUES (10, N'培训申请流程
', N'T_px
', N'PXInfo', N'T|U|D|2|1|7', N'FT_px', 10)
INSERT [dbo].[T_flow] ([id], [formname], [tablename], [pagename], [flow], [fieldtable], [templateid]) VALUES (11, N'固定资产申请流程
', N'T_gdzc
', N'GDZCInfo', N'T|U|D|2|1|6|7', N'FT_gdzc', 11)
INSERT [dbo].[T_flow] ([id], [formname], [tablename], [pagename], [flow], [fieldtable], [templateid]) VALUES (12, N'暂支申请流程
', N'T_zz
', N'ZZInfo', N'T|U|D|2|1|6|6', N'FT_zz', 12)
INSERT [dbo].[T_flow] ([id], [formname], [tablename], [pagename], [flow], [fieldtable], [templateid]) VALUES (13, N'课时费统计流程
', N'T_bgwj
', N'CommonModelInfo', N'T|U|D|2|1|7', N'FT_attachmodel', 1)
INSERT [dbo].[T_flow] ([id], [formname], [tablename], [pagename], [flow], [fieldtable], [templateid]) VALUES (14, N'教材费统计流程
', N'T_attachmodel
', N'CommonModelInfo', N'T|U|D|2|1|7', N'FT_attachmodel', 1)
INSERT [dbo].[T_flow] ([id], [formname], [tablename], [pagename], [flow], [fieldtable], [templateid]) VALUES (15, N'平台信息发布流程
', N'T_attachmodel
', N'CommonModelInfo', N'T|U|D|2|0', N'FT_attachmodel', 1)
SET IDENTITY_INSERT [dbo].[T_flow] OFF
SET IDENTITY_INSERT [dbo].[T_flowname] ON 

INSERT [dbo].[T_flowname] ([id], [flowname], [symbol]) VALUES (1, N'员工填写', N'T')
INSERT [dbo].[T_flowname] ([id], [flowname], [symbol]) VALUES (2, N'上级主管审批', N'U')
INSERT [dbo].[T_flowname] ([id], [flowname], [symbol]) VALUES (3, N'部门主管审批', N'D')
INSERT [dbo].[T_flowname] ([id], [flowname], [symbol]) VALUES (4, N'二级主管审批', N'2')
INSERT [dbo].[T_flowname] ([id], [flowname], [symbol]) VALUES (5, N'一级主管审批', N'1')
INSERT [dbo].[T_flowname] ([id], [flowname], [symbol]) VALUES (6, N'财务审核', N'6')
INSERT [dbo].[T_flowname] ([id], [flowname], [symbol]) VALUES (7, N'人事留档', N'7')
INSERT [dbo].[T_flowname] ([id], [flowname], [symbol]) VALUES (8, N'财务留档', N'6')
INSERT [dbo].[T_flowname] ([id], [flowname], [symbol]) VALUES (9, N'其他留档', N'0')
SET IDENTITY_INSERT [dbo].[T_flowname] OFF
SET IDENTITY_INSERT [dbo].[T_formflow] ON 

INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (42, 2, 1, 12, CAST(0x0000A47300D98CF6 AS DateTime), 9, 2, N'9|2|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (44, 3, 1, 12, CAST(0x0000A473010AE444 AS DateTime), 9, 2, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (45, 1, 1, 12, CAST(0x0000A47400B41781 AS DateTime), 9, 2, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (46, 2, 2, 12, CAST(0x0000A47400CB242C AS DateTime), 0, 1, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (47, 2, 3, 12, CAST(0x0000A47500B26C4B AS DateTime), 0, 1, N'9|2|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (48, 7, 1, 12, CAST(0x0000A47900A59766 AS DateTime), 2, 2, N'9|2|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (49, 5, 1, 12, CAST(0x0000A47900BA83BA AS DateTime), 9, 2, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (50, 9, 1, 12, CAST(0x0000A4790103DFF6 AS DateTime), 1, 2, N'1|0')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (51, 5, 2, 12, CAST(0x0000A479010FC2E0 AS DateTime), 0, 1, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (52, 9, 2, 12, CAST(0x0000A479010FEB6F AS DateTime), 1, 2, N'1|0')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (53, 10, 1, 12, CAST(0x0000A47901111346 AS DateTime), 9, 2, N'9|2|1|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (54, 14, 1, 12, CAST(0x0000A47B009D6C6D AS DateTime), 2, 2, N'9|2|1|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (55, 13, 2, 12, CAST(0x0000A47B009D77B4 AS DateTime), 9, 2, N'9|2|1|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (56, 15, 3, 12, CAST(0x0000A47B009D850B AS DateTime), 9, 2, N'9|2|0')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (57, 6, 4, 12, CAST(0x0000A47B009D90A8 AS DateTime), 9, 2, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (58, 2, 4, 12, CAST(0x0000A4830131C9A1 AS DateTime), 0, 1, N'9|2|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (59, 5, 3, 12, CAST(0x0000A48301334A57 AS DateTime), 0, 1, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (60, 4, 2, 12, CAST(0x0000A4830140D970 AS DateTime), 6, 2, N'6|2')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (61, 4, 3, 12, CAST(0x0000A4860094AB8F AS DateTime), 6, 2, N'6|2')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (62, 4, 4, 12, CAST(0x0000A48600957F14 AS DateTime), 6, 2, N'6|2')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (63, 4, 5, 12, CAST(0x0000A48600ACFBC5 AS DateTime), 6, 2, N'6|2')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (64, 4, 6, 12, CAST(0x0000A48600CEF19A AS DateTime), 6, 2, N'6|2')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (65, 4, 7, 12, CAST(0x0000A48600D0940F AS DateTime), 6, 2, N'6|2')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (66, 4, 8, 12, CAST(0x0000A48600D2650A AS DateTime), 6, 2, N'6|2')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (67, 4, 9, 12, CAST(0x0000A48600D2A656 AS DateTime), 6, 2, N'6|2')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (68, 4, 10, 12, CAST(0x0000A48600D2D067 AS DateTime), 6, 2, N'6|2')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (69, 4, 11, 12, CAST(0x0000A48600D2EF63 AS DateTime), 6, 2, N'6|2')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (70, 4, 12, 12, CAST(0x0000A48600D549B3 AS DateTime), 0, 1, N'6|2')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (71, 4, 13, 12, CAST(0x0000A48600D58535 AS DateTime), 0, 1, N'6|2')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (72, 4, 14, 12, CAST(0x0000A48600EB25F3 AS DateTime), 0, 1, N'6|2')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (73, 5, 4, 12, CAST(0x0000A48600D9F387 AS DateTime), 9, 2, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (74, 5, 5, 12, CAST(0x0000A48600E599ED AS DateTime), 9, 2, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (75, 5, 6, 12, CAST(0x0000A48600E87107 AS DateTime), 9, 2, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (76, 5, 7, 12, CAST(0x0000A48600E91A9D AS DateTime), 9, 2, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (77, 5, 8, 12, CAST(0x0000A48600E972C6 AS DateTime), 9, 2, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (78, 5, 9, 12, CAST(0x0000A48600ED9FB0 AS DateTime), 0, 1, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (79, 5, 10, 12, CAST(0x0000A48600EDEDAA AS DateTime), 0, 1, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (80, 5, 11, 12, CAST(0x0000A48600EFE5E8 AS DateTime), 0, 1, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (81, 5, 12, 12, CAST(0x0000A48600F07FA5 AS DateTime), 0, 1, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (82, 3, 2, 12, CAST(0x0000A48600F0C3F1 AS DateTime), 0, 1, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (83, 5, 13, 12, CAST(0x0000A48600F170C2 AS DateTime), 0, 1, N'9|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (84, 4, 15, 12, CAST(0x0000A48600F14E83 AS DateTime), 0, 1, N'6|2')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (85, 4, 16, 12, CAST(0x0000A48600F25021 AS DateTime), 0, 1, N'6|2')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (86, 4, 17, 12, CAST(0x0000A48600F84508 AS DateTime), 0, 1, N'6|2')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (87, 7, 2, 12, CAST(0x0000A48600FBD0FC AS DateTime), 0, 1, N'9|2|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (88, 8, 1, 12, CAST(0x0000A486010467E0 AS DateTime), 0, 1, N'9|2|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (89, 8, 2, 12, CAST(0x0000A48601048E5C AS DateTime), 0, 1, N'9|2|7')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (90, 9, 3, 12, CAST(0x0000A486010680C7 AS DateTime), 0, 1, N'1|0')
INSERT [dbo].[T_formflow] ([id], [formid], [forminnerid], [eid], [writetime], [nextstep], [state], [signposlist]) VALUES (91, 14, 5, 12, CAST(0x0000A486011362BE AS DateTime), 9, 2, N'9|2|1|7')
SET IDENTITY_INSERT [dbo].[T_formflow] OFF
SET IDENTITY_INSERT [dbo].[T_fybx] ON 

INSERT [dbo].[T_fybx] ([id], [usage], [happendate], [money], [bmoney], [prepay], [returnpay], [attachpath]) VALUES (2, N'1', CAST(0xDE390B00 AS Date), CAST(1.00 AS Decimal(15, 2)), N'1', CAST(1.00 AS Decimal(15, 2)), CAST(1.00 AS Decimal(15, 2)), N'<p>11111111112222222223333333333</p><table><tbody><tr class="firstRow"><td valign="top" width="274"><br/></td><td valign="top" width="274"><br/></td><td valign="top" width="274"><br/></td></tr><tr><td valign="top" width="274"><br/></td><td valign="top" width="274"><br/></td><td valign="top" width="274"><br/></td></tr><tr><td valign="top" width="274"><br/></td><td valign="top" width="274"><br/></td><td valign="top" width="274"><br/></td></tr></tbody></table><p><br/></p>')
INSERT [dbo].[T_fybx] ([id], [usage], [happendate], [money], [bmoney], [prepay], [returnpay], [attachpath]) VALUES (3, N'1', CAST(0xE1390B00 AS Date), CAST(1.00 AS Decimal(15, 2)), N'1', CAST(1.00 AS Decimal(15, 2)), CAST(1.00 AS Decimal(15, 2)), N'<p>哈哈哈哈哈哈<br/></p>')
INSERT [dbo].[T_fybx] ([id], [usage], [happendate], [money], [bmoney], [prepay], [returnpay], [attachpath]) VALUES (4, N'1', CAST(0xE1390B00 AS Date), CAST(1.00 AS Decimal(15, 2)), N'1', CAST(1.00 AS Decimal(15, 2)), CAST(1.00 AS Decimal(15, 2)), N'<table><tbody><tr class="firstRow"><td style="word-break: break-all;" valign="top" width="274">1<br/></td><td style="word-break: break-all;" valign="top" width="274">1<br/></td><td style="word-break: break-all;" valign="top" width="274">1<br/></td></tr><tr><td style="word-break: break-all;" valign="top" width="274">2<br/></td><td style="word-break: break-all;" valign="top" width="274">2<br/></td><td style="word-break: break-all;" valign="top" width="274">2<br/></td></tr><tr><td style="word-break: break-all;" valign="top" width="274">3<br/></td><td style="word-break: break-all;" valign="top" width="274">3<br/></td><td style="word-break: break-all;" valign="top" width="274">3<br/></td></tr></tbody></table><p><br/></p>')
INSERT [dbo].[T_fybx] ([id], [usage], [happendate], [money], [bmoney], [prepay], [returnpay], [attachpath]) VALUES (5, N'1', CAST(0xE1390B00 AS Date), CAST(1.00 AS Decimal(15, 2)), N'1', CAST(1.00 AS Decimal(15, 2)), CAST(1.00 AS Decimal(15, 2)), N'<table cellpadding="0" cellspacing="0" width="758"><colgroup><col style=";width:111px" width="110"/><col style="width:72px" span="9" width="72"/></colgroup><tbody><tr class="firstRow" style="height:39px" height="39"><td colspan="9" style="" width="687" height="39">每月培养好习惯（生活篇）</td><td style="" width="72"><br/></td></tr><tr style="height:20px" height="20"><td colspan="9" style="" height="20">（置换旧习惯，变成新习惯）</td><td><br/></td></tr><tr style="height:23px" height="23"><td colspan="9" style="" height="23">2015年 4&nbsp;&nbsp; 月</td><td><br/></td></tr><tr style="height:27px" height="27"><td colspan="9" style="border-right: 1px solid black;" height="27"><br/></td><td><br/></td></tr><tr style=";height:23px" height="23"><td rowspan="4" style="border-bottom: 1px solid black; border-top: medium none;" width="111" height="100">Jasmine</td><td style="border-top:none;border-left:none">旧习惯1</td><td style="border-top:none;border-left:none">旧习惯2</td><td style="border-top:none;border-left:none">旧习惯3</td><td style="border-top:none;border-left:none">旧习惯4</td><td style="border-top:none;border-left:none">旧习惯5</td><td style="border-top:none;border-left:none">旧习惯6</td><td style="border-top:none;border-left:none">旧习惯7</td><td rowspan="3" style="border-top: medium none;" width="72"><br/></td><td><br/></td></tr><tr style="height:22px" height="22"><td style="border-top: medium none; border-left: medium none;" width="72" height="22"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="" width="72"><br/></td></tr><tr style=";height:23px" height="23"><td style="border-top: medium none; border-left: medium none;" height="23">新习惯1</td><td style="border-top:none;border-left:none">新习惯2</td><td style="border-top:none;border-left:none">新习惯3</td><td style="border-top:none;border-left:none">新习惯4</td><td style="border-top:none;border-left:none">新习惯5</td><td style="border-top:none;border-left:none">新习惯6</td><td style="border-top:none;border-left:none">新习惯7</td><td><br/></td></tr><tr style="height:32px" height="32"><td style="border-top: medium none; border-left: medium none;" width="72" height="32"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72">这天做到多少项：</td><td style="" width="72"><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">1</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">2</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">3</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">4</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">5</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">6</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">7</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">8</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">9</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td><br/></td></tr></tbody></table><p><br/></p>')
INSERT [dbo].[T_fybx] ([id], [usage], [happendate], [money], [bmoney], [prepay], [returnpay], [attachpath]) VALUES (6, N'1', CAST(0xE1390B00 AS Date), CAST(1.00 AS Decimal(15, 2)), N'1', CAST(1.00 AS Decimal(15, 2)), CAST(1.00 AS Decimal(15, 2)), N'<table cellpadding="0" cellspacing="0" width="686"><colgroup><col style=";width:111px" width="110"/><col style="width:72px" span="8" width="72"/></colgroup><tbody><tr class="firstRow" style=";height:23px" height="23"><td rowspan="4" style="border-bottom: 1px solid black;" width="111" height="100">Jasmine</td><td style="border-left: medium none;" width="72">旧习惯1</td><td style="border-left: medium none;" width="72">旧习惯2</td><td style="border-left: medium none;" width="72">旧习惯3</td><td style="border-left: medium none;" width="72">旧习惯4</td><td style="border-left: medium none;" width="72">旧习惯5</td><td style="border-left: medium none;" width="72">旧习惯6</td><td style="border-left: medium none;" width="72">旧习惯7</td><td rowspan="3" style="" width="72"><br/></td></tr><tr style="height:22px" height="22"><td style="border-top: medium none; border-left: medium none;" width="72" height="22"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td></tr><tr style=";height:23px" height="23"><td style="border-top: medium none; border-left: medium none;" height="23">新习惯1</td><td style="border-top:none;border-left:none">新习惯2</td><td style="border-top:none;border-left:none">新习惯3</td><td style="border-top:none;border-left:none">新习惯4</td><td style="border-top:none;border-left:none">新习惯5</td><td style="border-top:none;border-left:none">新习惯6</td><td style="border-top:none;border-left:none">新习惯7</td></tr><tr style="height:32px" height="32"><td style="border-top: medium none; border-left: medium none;" width="72" height="32"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72">这天做到多少项：</td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">1</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">2</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">3</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">4</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td></tr></tbody></table><p><br/></p>')
INSERT [dbo].[T_fybx] ([id], [usage], [happendate], [money], [bmoney], [prepay], [returnpay], [attachpath]) VALUES (7, N'1', CAST(0xE1390B00 AS Date), CAST(1.00 AS Decimal(15, 2)), N'1', CAST(1.00 AS Decimal(15, 2)), CAST(1.00 AS Decimal(15, 2)), N'<table interlaced="enabled" cellpadding="0" cellspacing="0" width="686"><colgroup><col style=";width:111px" width="110"/><col style="width:72px" span="8" width="72"/></colgroup><tbody><tr class="ue-table-interlace-color-single firstRow" style=";height:23px" height="23"><td rowspan="4" style="border-width: 1px; border-style: solid;" width="111" height="100">Jasmine</td><td style="border-width: 1px; border-style: solid; border-left: 1px solid;" width="72">旧习惯1</td><td style="border-width: 1px; border-style: solid; border-left: 1px solid;" width="72">旧习惯2</td><td style="border-width: 1px; border-style: solid; border-left: 1px solid;" width="72">旧习惯3</td><td style="border-width: 1px; border-style: solid; border-left: 1px solid;" width="72">旧习惯4</td><td style="border-width: 1px; border-style: solid; border-left: 1px solid;" width="72">旧习惯5</td><td style="border-width: 1px; border-style: solid; border-left: 1px solid;" width="72">旧习惯6</td><td style="border-width: 1px; border-style: solid; border-left: 1px solid;" width="72">旧习惯7</td><td rowspan="3" style="border-width: 1px; border-style: solid;" width="72"><br/></td></tr><tr class="ue-table-interlace-color-double" style="height:22px" height="22"><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;" width="72" height="22"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;" width="72"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;" width="72"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;" width="72"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;" width="72"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;" width="72"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;" width="72"><br/></td></tr><tr class="ue-table-interlace-color-single" style=";height:23px" height="23"><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;" height="23">新习惯1</td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;">新习惯2</td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;">新习惯3</td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;">新习惯4</td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;">新习惯5</td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;">新习惯6</td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;">新习惯7</td></tr><tr class="ue-table-interlace-color-double" style="height:32px" height="32"><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;" width="72" height="32"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;" width="72"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;" width="72"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;" width="72"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;" width="72"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;" width="72"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;" width="72"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;" width="72">这天做到多少项：</td></tr><tr class="ue-table-interlace-color-single" style="height:19px" height="19"><td style="border-width: 1px; border-style: solid; border-top: 1px solid;" height="19">1</td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td></tr><tr class="ue-table-interlace-color-double" style="height:19px" height="19"><td style="border-width: 1px; border-style: solid; border-top: 1px solid;" height="19">2</td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td></tr><tr class="ue-table-interlace-color-single" style="height:19px" height="19"><td style="border-width: 1px; border-style: solid; border-top: 1px solid;" height="19">3</td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td></tr><tr class="ue-table-interlace-color-double" style="height:19px" height="19"><td style="border-width: 1px; border-style: solid; border-top: 1px solid;" height="19">4</td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td><td style="border-width: 1px; border-style: solid; border-top: 1px solid; border-left: 1px solid;"><br/></td></tr></tbody></table><p><br/></p>')
INSERT [dbo].[T_fybx] ([id], [usage], [happendate], [money], [bmoney], [prepay], [returnpay], [attachpath]) VALUES (8, N'1', CAST(0xE1390B00 AS Date), CAST(1.00 AS Decimal(15, 2)), N'1', CAST(1.00 AS Decimal(15, 2)), CAST(1.00 AS Decimal(15, 2)), N'<table cellpadding="0" cellspacing="0" width="829"><colgroup><col style=";width:111px" width="110"/><col style="width:72px" span="8" width="72"/></colgroup><tbody><tr class="firstRow" style=";height:23px" height="23"><td rowspan="4" style="border-color: rgb(0, 0, 0);" width="134" height="100">Jasmine</td><td style="border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">旧习惯1</td><td style="border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">旧习惯2</td><td style="border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">旧习惯3</td><td style="border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">旧习惯4</td><td style="border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">旧习惯5</td><td style="border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">旧习惯6</td><td style="border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">旧习惯7</td><td rowspan="3" style="border-color: rgb(0, 0, 0);" width="87"><br/></td></tr><tr style="height:22px" height="22"><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87" height="22"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td></tr><tr style=";height:23px" height="23"><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87" height="23">新习惯1</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">新习惯2</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">新习惯3</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">新习惯4</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">新习惯5</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">新习惯6</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">新习惯7</td></tr><tr style="height:32px" height="32"><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87" height="32"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">这天做到多少项：</td></tr><tr style="height:19px" height="19"><td style="border-top: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="134" height="19">1</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="134" height="19">2</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="134" height="19">3</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="134" height="19">4</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td></tr></tbody></table><p><br/></p>')
INSERT [dbo].[T_fybx] ([id], [usage], [happendate], [money], [bmoney], [prepay], [returnpay], [attachpath]) VALUES (9, N'1', CAST(0xE1390B00 AS Date), CAST(1.00 AS Decimal(15, 2)), N'1', CAST(1.00 AS Decimal(15, 2)), CAST(1.00 AS Decimal(15, 2)), N'<table cellpadding="0" cellspacing="0" width="829"><colgroup><col style=";width:111px" width="110"/><col style="width:72px" span="8" width="72"/></colgroup><tbody><tr class="firstRow" style=";height:23px" height="23"><td rowspan="4" style="border-color: rgb(0, 0, 0);" width="134" height="100">Jasmine</td><td style="border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">旧习惯1</td><td style="border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">旧习惯2</td><td style="border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">旧习惯3</td><td style="border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">旧习惯4</td><td style="border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">旧习惯5</td><td style="border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">旧习惯6</td><td style="border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">旧习惯7</td><td rowspan="3" style="border-color: rgb(0, 0, 0);" width="87"><br/></td></tr><tr style="height:22px" height="22"><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87" height="22"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td></tr><tr style=";height:23px" height="23"><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87" height="23">新习惯1</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">新习惯2</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">新习惯3</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">新习惯4</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">新习惯5</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">新习惯6</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">新习惯7</td></tr><tr style="height:32px" height="32"><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87" height="32"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87">这天做到多少项：</td></tr><tr style="height:19px" height="19"><td style="border-top: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="134" height="19">1</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="134" height="19">2</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="134" height="19">3</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="134" height="19">4</td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td><td style="border-top: medium none rgb(0, 0, 0); border-left: medium none rgb(0, 0, 0); border-color: rgb(0, 0, 0);" width="87"><br/></td></tr></tbody></table><p><br/></p>')
INSERT [dbo].[T_fybx] ([id], [usage], [happendate], [money], [bmoney], [prepay], [returnpay], [attachpath]) VALUES (10, N'1', CAST(0xE1390B00 AS Date), CAST(1.00 AS Decimal(15, 2)), N'1', CAST(1.00 AS Decimal(15, 2)), CAST(1.00 AS Decimal(15, 2)), N'<table cellpadding="0" cellspacing="0" width="686"><colgroup><col style=";width:111px" width="110"/><col style="width:72px" span="8" width="72"/></colgroup><tbody><tr class="firstRow" style=";height:23px" height="23"><td rowspan="4" style="" width="111" height="100">Jasmine</td><td style="border-left: medium none;" width="72">旧习惯1</td><td style="border-left: medium none;" width="72">旧习惯2</td><td style="border-left: medium none;" width="72">旧习惯3</td><td style="border-left: medium none;" width="72">旧习惯4</td><td style="border-left: medium none;" width="72">旧习惯5</td><td style="border-left: medium none;" width="72">旧习惯6</td><td style="border-left: medium none;" width="72">旧习惯7</td><td rowspan="3" style="" width="72"><br/></td></tr><tr style="height:22px" height="22"><td style="border-top: medium none; border-left: medium none;" width="72" height="22"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td></tr><tr style=";height:23px" height="23"><td style="border-top: medium none; border-left: medium none;" height="23">新习惯1</td><td style="border-top:none;border-left:none">新习惯2</td><td style="border-top:none;border-left:none">新习惯3</td><td style="border-top:none;border-left:none">新习惯4</td><td style="border-top:none;border-left:none">新习惯5</td><td style="border-top:none;border-left:none">新习惯6</td><td style="border-top:none;border-left:none">新习惯7</td></tr><tr style="height:32px" height="32"><td style="border-top: medium none; border-left: medium none;" width="72" height="32"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72">这天做到多少项：</td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">1</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">2</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">3</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">4</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td></tr></tbody></table><p><br/></p>')
INSERT [dbo].[T_fybx] ([id], [usage], [happendate], [money], [bmoney], [prepay], [returnpay], [attachpath]) VALUES (11, N'1', CAST(0xE1390B00 AS Date), CAST(1.00 AS Decimal(15, 2)), N'1', CAST(1.00 AS Decimal(15, 2)), CAST(1.00 AS Decimal(15, 2)), N'<table cellpadding="0" cellspacing="0" width="686"><colgroup><col style=";width:111px" width="110"/><col style="width:72px" span="8" width="72"/></colgroup><tbody><tr class="firstRow" style=";height:23px" height="23"><td rowspan="4" style="" width="111" height="100">Jasmine</td><td style="border-left: medium none;" width="72">旧习惯1</td><td style="border-left: medium none;" width="72">旧习惯2</td><td style="border-left: medium none;" width="72">旧习惯3</td><td style="border-left: medium none;" width="72">旧习惯4</td><td style="border-left: medium none;" width="72">旧习惯5</td><td style="border-left: medium none;" width="72">旧习惯6</td><td style="border-left: medium none;" width="72">旧习惯7</td><td rowspan="3" style="" width="72"><br/></td></tr><tr style="height:22px" height="22"><td style="border-top: medium none; border-left: medium none;" width="72" height="22"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td></tr><tr style=";height:23px" height="23"><td style="border-top: medium none; border-left: medium none;" height="23">新习惯1</td><td style="border-top:none;border-left:none">新习惯2</td><td style="border-top:none;border-left:none">新习惯3</td><td style="border-top:none;border-left:none">新习惯4</td><td style="border-top:none;border-left:none">新习惯5</td><td style="border-top:none;border-left:none">新习惯6</td><td style="border-top:none;border-left:none">新习惯7</td></tr><tr style="height:32px" height="32"><td style="border-top: medium none; border-left: medium none;" width="72" height="32"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72"><br/></td><td style="border-top: medium none; border-left: medium none;" width="72">这天做到多少项：</td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">1</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">2</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">3</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td></tr><tr style="height:19px" height="19"><td style="border-top: medium none;" height="19">4</td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td><td style="border-top:none;border-left:none"><br/></td></tr></tbody></table><p><br/></p>')
INSERT [dbo].[T_fybx] ([id], [usage], [happendate], [money], [bmoney], [prepay], [returnpay], [attachpath]) VALUES (12, N'1', CAST(0xE1390B00 AS Date), CAST(1.00 AS Decimal(15, 2)), N'1', CAST(1.00 AS Decimal(15, 2)), CAST(1.00 AS Decimal(15, 2)), N'<p>121<br/></p>')
INSERT [dbo].[T_fybx] ([id], [usage], [happendate], [money], [bmoney], [prepay], [returnpay], [attachpath]) VALUES (13, N'1', CAST(0xE1390B00 AS Date), CAST(1.00 AS Decimal(15, 2)), N'1', CAST(1.00 AS Decimal(15, 2)), CAST(1.00 AS Decimal(15, 2)), N'<p>1<br/></p>')
INSERT [dbo].[T_fybx] ([id], [usage], [happendate], [money], [bmoney], [prepay], [returnpay], [attachpath]) VALUES (14, N'1', CAST(0xE1390B00 AS Date), CAST(1.00 AS Decimal(15, 2)), N'1', CAST(1.00 AS Decimal(15, 2)), CAST(1.00 AS Decimal(15, 2)), N'<p>1<br/></p>')
INSERT [dbo].[T_fybx] ([id], [usage], [happendate], [money], [bmoney], [prepay], [returnpay], [attachpath]) VALUES (15, N'1', CAST(0xE2390B00 AS Date), CAST(1.00 AS Decimal(15, 2)), N'1', CAST(1.00 AS Decimal(15, 2)), CAST(1.00 AS Decimal(15, 2)), N'<p>1<br/></p>')
INSERT [dbo].[T_fybx] ([id], [usage], [happendate], [money], [bmoney], [prepay], [returnpay], [attachpath]) VALUES (16, N'1', CAST(0xE1390B00 AS Date), CAST(1.00 AS Decimal(15, 2)), N'1', CAST(1.00 AS Decimal(15, 2)), CAST(1.00 AS Decimal(15, 2)), N'<p>21<br/></p>')
INSERT [dbo].[T_fybx] ([id], [usage], [happendate], [money], [bmoney], [prepay], [returnpay], [attachpath]) VALUES (17, N'1', CAST(0xE1390B00 AS Date), CAST(1.00 AS Decimal(15, 2)), N'1', CAST(1.00 AS Decimal(15, 2)), CAST(1.00 AS Decimal(15, 2)), N'<p>12321321<br/></p>')
SET IDENTITY_INSERT [dbo].[T_fybx] OFF
SET IDENTITY_INSERT [dbo].[T_gc] ON 

INSERT [dbo].[T_gc] ([id], [begintime], [endtime], [reason]) VALUES (1, CAST(0x0000A472010ACB38 AS DateTime), CAST(0x0000A473010AD240 AS DateTime), N'周会')
INSERT [dbo].[T_gc] ([id], [begintime], [endtime], [reason]) VALUES (2, CAST(0x0000A48600000000 AS DateTime), CAST(0x0000A48800F099C0 AS DateTime), N'1')
SET IDENTITY_INSERT [dbo].[T_gc] OFF
SET IDENTITY_INSERT [dbo].[T_hyjl] ON 

INSERT [dbo].[T_hyjl] ([id], [meetingdate], [topic], [attachcontent]) VALUES (1, CAST(0xD4390B00 AS Date), N'会议', N'会议')
INSERT [dbo].[T_hyjl] ([id], [meetingdate], [topic], [attachcontent]) VALUES (2, CAST(0xD6390B00 AS Date), N'1', N'1')
INSERT [dbo].[T_hyjl] ([id], [meetingdate], [topic], [attachcontent]) VALUES (3, CAST(0xDE390B00 AS Date), N'1', N'1')
INSERT [dbo].[T_hyjl] ([id], [meetingdate], [topic], [attachcontent]) VALUES (4, CAST(0xE1390B00 AS Date), N'1', N'<p>1<br/></p>')
INSERT [dbo].[T_hyjl] ([id], [meetingdate], [topic], [attachcontent]) VALUES (5, CAST(0xE1390B00 AS Date), N'1', N'<table><tbody><tr class="firstRow"><td style="word-break: break-all;" valign="top" width="268">1<br/></td><td valign="top" width="268"><br/></td><td valign="top" width="268"><br/></td></tr><tr><td style="word-break: break-all;" valign="top" width="268">2<br/></td><td valign="top" width="268"><br/></td><td valign="top" width="268"><br/></td></tr><tr><td style="word-break: break-all;" valign="top" width="268">3<br/></td><td valign="top" width="268"><br/></td><td valign="top" width="268"><br/></td></tr></tbody></table><p><br/></p>')
INSERT [dbo].[T_hyjl] ([id], [meetingdate], [topic], [attachcontent]) VALUES (6, CAST(0xE1390B00 AS Date), N'1', N'<table><tbody><tr class="firstRow"><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="268">2<br/></td><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="268">3<br/></td><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="268">1<br/></td></tr><tr><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="268">2<br/></td><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="268">3<br/></td><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="268">1<br/></td></tr><tr><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="268">2<br/></td><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="268">3<br/></td><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="268">1<br/></td></tr></tbody></table><p><br/></p>')
INSERT [dbo].[T_hyjl] ([id], [meetingdate], [topic], [attachcontent]) VALUES (7, CAST(0xE1390B00 AS Date), N'1', N'<table><tbody><tr class="firstRow"><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="152">1<br/></td><td style="border:1px solid #ccc;" valign="top" width="152"><br/></td><td style="border:1px solid #ccc;" valign="top" width="152"><br/></td><td style="border:1px solid #ccc;" valign="top" width="152"><br/></td><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="152">6<br/></td></tr><tr><td style="border:1px solid #ccc;" valign="top" width="152"><br/></td><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="152">2<br/></td><td style="border:1px solid #ccc;" valign="top" width="152"><br/></td><td style="border:1px solid #ccc;" valign="top" width="152"><br/></td><td style="border:1px solid #ccc;" valign="top" width="152"><br/></td></tr><tr><td style="border:1px solid #ccc;" valign="top" width="152"><br/></td><td style="border:1px solid #ccc;" valign="top" width="152"><br/></td><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="152">3<br/></td><td style="border:1px solid #ccc;" valign="top" width="152"><br/></td><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="152">5<br/></td></tr><tr><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="152">7<br/></td><td style="border:1px solid #ccc;" valign="top" width="152"><br/></td><td style="border:1px solid #ccc;" valign="top" width="152"><br/></td><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="152">4<br/></td><td style="border:1px solid #ccc;" valign="top" width="152"><br/></td></tr></tbody></table><p><br/></p>')
INSERT [dbo].[T_hyjl] ([id], [meetingdate], [topic], [attachcontent]) VALUES (8, CAST(0xDA390B00 AS Date), N'1', N'<table><tbody><tr class="firstRow"><td style="border:1px solid #ccc;" valign="top" width="196"><br/></td><td style="border:1px solid #ccc;" valign="top" width="196"><br/></td><td style="border:1px solid #ccc;" valign="top" width="196"><br/></td><td style="border:1px solid #ccc;" valign="top" width="196"><br/></td></tr><tr><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="196">2<br/></td><td style="border:1px solid #ccc;" valign="top" width="196"><br/></td><td style="border:1px solid #ccc;" valign="top" width="196"><br/></td><td style="border:1px solid #ccc;" valign="top" width="196"><br/></td></tr><tr><td style="border:1px solid #ccc;" valign="top" width="196"><br/></td><td style="border:1px solid #ccc;" valign="top" width="196"><br/></td><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="196">5<br/></td><td style="border:1px solid #ccc;" valign="top" width="196"><br/></td></tr><tr><td style="border:1px solid #ccc;" valign="top" width="196"><br/></td><td style="border:1px solid #ccc;" valign="top" width="196"><br/></td><td style="border:1px solid #ccc;" valign="top" width="196"><br/></td><td style="border:1px solid #ccc;" valign="top" width="196"><br/></td></tr></tbody></table><p><br/></p>')
INSERT [dbo].[T_hyjl] ([id], [meetingdate], [topic], [attachcontent]) VALUES (9, CAST(0xE1390B00 AS Date), N'1', N'<p>1231232</p><table><tbody><tr class="firstRow"><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="268">2<br/></td><td style="border:1px solid #ccc;" valign="top" width="268"><br/></td><td style="border:1px solid #ccc;" valign="top" width="268"><br/></td></tr><tr><td style="border:1px solid #ccc;" valign="top" width="268"><br/></td><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="268">4<br/></td><td style="border:1px solid #ccc;" valign="top" width="268"><br/></td></tr><tr><td style="border:1px solid #ccc;" valign="top" width="268"><br/></td><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="268">F<br/></td><td style="border:1px solid #ccc;" valign="top" width="268"><br/></td></tr><tr><td style="border:1px solid #ccc;" valign="top" width="268"><br/></td><td style="border:1px solid #ccc;" valign="top" width="268"><br/></td><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="268">H<br/></td></tr></tbody></table><p><br/></p>')
INSERT [dbo].[T_hyjl] ([id], [meetingdate], [topic], [attachcontent]) VALUES (10, CAST(0xE1390B00 AS Date), N'1', N'<p>12321321<br/></p>')
INSERT [dbo].[T_hyjl] ([id], [meetingdate], [topic], [attachcontent]) VALUES (11, CAST(0xE1390B00 AS Date), N'1', N'<p>123qwe<br/></p>')
INSERT [dbo].[T_hyjl] ([id], [meetingdate], [topic], [attachcontent]) VALUES (12, CAST(0xE1390B00 AS Date), N'1', N'<p>的反光镜的撒SDF<br/></p>')
INSERT [dbo].[T_hyjl] ([id], [meetingdate], [topic], [attachcontent]) VALUES (13, CAST(0xE1390B00 AS Date), N'1', N'<p>123<br/></p>')
SET IDENTITY_INSERT [dbo].[T_hyjl] OFF
SET IDENTITY_INSERT [dbo].[T_jb] ON 

INSERT [dbo].[T_jb] ([id], [begintime], [endtime], [totaltime], [reason], [typeid]) VALUES (1, CAST(0x0000A47400B3F4C0 AS DateTime), CAST(0x0000A47400F5E59C AS DateTime), 4, N'加班', 8)
SET IDENTITY_INSERT [dbo].[T_jb] OFF
SET IDENTITY_INSERT [dbo].[T_option] ON 

INSERT [dbo].[T_option] ([id], [formflowid], [employeeid], [signtime], [resultid], [reason]) VALUES (1, 1, 4, CAST(0x0000A46200FBF658 AS DateTime), 1, NULL)
INSERT [dbo].[T_option] ([id], [formflowid], [employeeid], [signtime], [resultid], [reason]) VALUES (2, 19, 4, CAST(0x0000A46D00BA4C31 AS DateTime), 1, N'')
INSERT [dbo].[T_option] ([id], [formflowid], [employeeid], [signtime], [resultid], [reason]) VALUES (3, 13, 4, CAST(0x0000A46D00BA6C21 AS DateTime), 1, N'')
INSERT [dbo].[T_option] ([id], [formflowid], [employeeid], [signtime], [resultid], [reason]) VALUES (4, 20, 4, CAST(0x0000A46D00BAB7DC AS DateTime), 1, N'')
INSERT [dbo].[T_option] ([id], [formflowid], [employeeid], [signtime], [resultid], [reason]) VALUES (5, 1, 4, CAST(0x0000A46D00BBD66A AS DateTime), 1, N'1212')
INSERT [dbo].[T_option] ([id], [formflowid], [employeeid], [signtime], [resultid], [reason]) VALUES (6, 11, 4, CAST(0x0000A46D00BBE16B AS DateTime), 1, N'去去去')
INSERT [dbo].[T_option] ([id], [formflowid], [employeeid], [signtime], [resultid], [reason]) VALUES (7, 23, 4, CAST(0x0000A46D00DBC98B AS DateTime), 1, N'')
INSERT [dbo].[T_option] ([id], [formflowid], [employeeid], [signtime], [resultid], [reason]) VALUES (8, 22, 4, CAST(0x0000A46D00E02C59 AS DateTime), 1, N'')
INSERT [dbo].[T_option] ([id], [formflowid], [employeeid], [signtime], [resultid], [reason]) VALUES (9, 20, 4, CAST(0x0000A46D00E1A001 AS DateTime), 1, N'')
INSERT [dbo].[T_option] ([id], [formflowid], [employeeid], [signtime], [resultid], [reason]) VALUES (10, 29, 4, CAST(0x0000A46E0170146F AS DateTime), 1, N'')
INSERT [dbo].[T_option] ([id], [formflowid], [employeeid], [signtime], [resultid], [reason]) VALUES (11, 28, 4, CAST(0x0000A46E01719116 AS DateTime), 2, N'')
INSERT [dbo].[T_option] ([id], [formflowid], [employeeid], [signtime], [resultid], [reason]) VALUES (12, 30, 7, CAST(0x0000A46E0178F80F AS DateTime), 1, N'')
INSERT [dbo].[T_option] ([id], [formflowid], [employeeid], [signtime], [resultid], [reason]) VALUES (13, 30, 3, CAST(0x0000A46E01791DCB AS DateTime), 1, N'')
INSERT [dbo].[T_option] ([id], [formflowid], [employeeid], [signtime], [resultid], [reason]) VALUES (14, 48, 12, CAST(0x0000A47F01862993 AS DateTime), 1, N'')
INSERT [dbo].[T_option] ([id], [formflowid], [employeeid], [signtime], [resultid], [reason]) VALUES (15, 54, 4, CAST(0x0000A47F01865285 AS DateTime), 1, N'')
SET IDENTITY_INSERT [dbo].[T_option] OFF
SET IDENTITY_INSERT [dbo].[T_position] ON 

INSERT [dbo].[T_position] ([id], [pname], [employeeid]) VALUES (1, N'一级主管', 1)
INSERT [dbo].[T_position] ([id], [pname], [employeeid]) VALUES (2, N'二级主管', 2)
INSERT [dbo].[T_position] ([id], [pname], [employeeid]) VALUES (3, N'教务部门主管', 3)
INSERT [dbo].[T_position] ([id], [pname], [employeeid]) VALUES (5, N'职员', 0)
INSERT [dbo].[T_position] ([id], [pname], [employeeid]) VALUES (6, N'财务部门主管', 5)
INSERT [dbo].[T_position] ([id], [pname], [employeeid]) VALUES (7, N'人事部门主管', 4)
INSERT [dbo].[T_position] ([id], [pname], [employeeid]) VALUES (8, N'招生部门主管', 6)
INSERT [dbo].[T_position] ([id], [pname], [employeeid]) VALUES (9, N'技术部门主管', 4)
INSERT [dbo].[T_position] ([id], [pname], [employeeid]) VALUES (10, N'行政部门主管', 4)
SET IDENTITY_INSERT [dbo].[T_position] OFF
SET IDENTITY_INSERT [dbo].[T_px] ON 

INSERT [dbo].[T_px] ([id], [begindate], [enddate], [typeid], [title], [attachcontent]) VALUES (1, CAST(0xD4390B00 AS Date), CAST(0xDE390B00 AS Date), 10, N'1', N'1')
SET IDENTITY_INSERT [dbo].[T_px] OFF
SET IDENTITY_INSERT [dbo].[T_qj] ON 

INSERT [dbo].[T_qj] ([id], [begintime], [endtime], [totaltime], [reason], [typeid]) VALUES (1, CAST(0x0000A47300977BB0 AS DateTime), CAST(0x0000A47300D96A34 AS DateTime), 4, N'哈哈', 4)
INSERT [dbo].[T_qj] ([id], [begintime], [endtime], [totaltime], [reason], [typeid]) VALUES (2, CAST(0x0000A47400BC7E4C AS DateTime), CAST(0x0000A47500FEF844 AS DateTime), 12.03, N'请假', 2)
INSERT [dbo].[T_qj] ([id], [begintime], [endtime], [totaltime], [reason], [typeid]) VALUES (3, CAST(0x0000A47500B173BC AS DateTime), CAST(0x0000A47C00B17740 AS DateTime), 56, N'请假', 2)
INSERT [dbo].[T_qj] ([id], [begintime], [endtime], [totaltime], [reason], [typeid]) VALUES (4, CAST(0x0000A4830131B1D0 AS DateTime), CAST(0x0000A48A0131B1D0 AS DateTime), 56, N'1', 1)
SET IDENTITY_INSERT [dbo].[T_qj] OFF
SET IDENTITY_INSERT [dbo].[T_qtjl] ON 

INSERT [dbo].[T_qtjl] ([id], [visitorid], [bevisitor], [property], [begintime], [endtime], [attachcontent]) VALUES (1, 1, N'1', N'1', CAST(0x0000A486010419F0 AS DateTime), CAST(0x0000A488010419F0 AS DateTime), N'<p>123453213<br/></p>')
INSERT [dbo].[T_qtjl] ([id], [visitorid], [bevisitor], [property], [begintime], [endtime], [attachcontent]) VALUES (2, 1, N'1', N'1', CAST(0x0000A48601046040 AS DateTime), CAST(0x0000A48801046040 AS DateTime), N'<p>123456423146758754325897<br/></p>')
SET IDENTITY_INSERT [dbo].[T_qtjl] OFF
SET IDENTITY_INSERT [dbo].[T_result] ON 

INSERT [dbo].[T_result] ([id], [description]) VALUES (1, N'同意')
INSERT [dbo].[T_result] ([id], [description]) VALUES (2, N'退回')
SET IDENTITY_INSERT [dbo].[T_result] OFF
SET IDENTITY_INSERT [dbo].[T_state] ON 

INSERT [dbo].[T_state] ([id], [statedesc]) VALUES (1, N'未发送')
INSERT [dbo].[T_state] ([id], [statedesc]) VALUES (2, N'进行中')
INSERT [dbo].[T_state] ([id], [statedesc]) VALUES (3, N'已完成')
INSERT [dbo].[T_state] ([id], [statedesc]) VALUES (4, N'被退回')
SET IDENTITY_INSERT [dbo].[T_state] OFF
SET IDENTITY_INSERT [dbo].[T_syqmkh] ON 

INSERT [dbo].[T_syqmkh] ([id], [entrydate], [passdate], [valuation]) VALUES (1, CAST(0xC8390B00 AS Date), CAST(0xE5390B00 AS Date), N'123')
INSERT [dbo].[T_syqmkh] ([id], [entrydate], [passdate], [valuation]) VALUES (2, CAST(0xE1390B00 AS Date), CAST(0xE5390B00 AS Date), N'<p>123456875432<br/></p>')
SET IDENTITY_INSERT [dbo].[T_syqmkh] OFF
SET IDENTITY_INSERT [dbo].[T_template] ON 

INSERT [dbo].[T_template] ([id], [templatename], [tablename], [pagename]) VALUES (1, N'通用模板                ', N'T_bgwj
            ', N'CommonModelInfo')
INSERT [dbo].[T_template] ([id], [templatename], [tablename], [pagename]) VALUES (2, N'加班申请模板              ', N'T_jb                ', N'JBInfo')
INSERT [dbo].[T_template] ([id], [templatename], [tablename], [pagename]) VALUES (3, N'请假申请模板              ', N'T_qj
              ', N'QJInfo')
INSERT [dbo].[T_template] ([id], [templatename], [tablename], [pagename]) VALUES (4, N'公出申请模板              ', N'T_gc
              ', N'GCInfo')
INSERT [dbo].[T_template] ([id], [templatename], [tablename], [pagename]) VALUES (5, N'费用报销模板              ', N'T_fybx
            ', N'FYBXInfo')
INSERT [dbo].[T_template] ([id], [templatename], [tablename], [pagename]) VALUES (6, N'会议记录模板              ', N'T_hyjl
            ', N'HYJLInfo')
INSERT [dbo].[T_template] ([id], [templatename], [tablename], [pagename]) VALUES (7, N'试用期满考核模板            ', N'T_syqmkh
          ', N'SYQMKHInfo')
INSERT [dbo].[T_template] ([id], [templatename], [tablename], [pagename]) VALUES (8, N'洽谈记录模板              ', N'T_qtjl
            ', N'QTJLInfo')
INSERT [dbo].[T_template] ([id], [templatename], [tablename], [pagename]) VALUES (9, N'薪资绩效申报模板            ', N'T_xzjx
            ', N'XZJXInfo')
INSERT [dbo].[T_template] ([id], [templatename], [tablename], [pagename]) VALUES (10, N'培训申请模板              ', N'T_px
              ', N'PXInfo')
INSERT [dbo].[T_template] ([id], [templatename], [tablename], [pagename]) VALUES (11, N'固定资产申请模板            ', N'T_gdzc
            ', N'GDZCInfo')
INSERT [dbo].[T_template] ([id], [templatename], [tablename], [pagename]) VALUES (12, N'暂支申请模板              ', N'T_zz
              ', N'ZZInfo')
SET IDENTITY_INSERT [dbo].[T_template] OFF
SET IDENTITY_INSERT [dbo].[T_user] ON 

INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (1, 1, N'zhangtianyun', N'202cb962ac59075b964b07152d234b70', 1, 0)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (2, 2, N'wangxinrui', N'202cb962ac59075b964b07152d234b70', 2, 0)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (3, 3, N'wangchunxia', N'202cb962ac59075b964b07152d234b70', 2, 0)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (4, 4, N'wanghui', N'202cb962ac59075b964b07152d234b70', 2, 0)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (5, 5, N'qianpeifen', N'202cb962ac59075b964b07152d234b70', 2, 0)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (6, 6, N'xiaolin', N'202cb962ac59075b964b07152d234b70', 2, 0)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (7, 7, N'mengfanyu', N'202cb962ac59075b964b07152d234b70', 3, 0)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (8, 8, N'shenjunjie', N'202cb962ac59075b964b07152d234b70', 3, 0)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (9, 9, N'shengxiaoxue', N'202cb962ac59075b964b07152d234b70', 3, 0)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (10, 10, N'zhangli', N'202cb962ac59075b964b07152d234b70', 3, 0)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (11, 11, N'jiangmengting', N'202cb962ac59075b964b07152d234b70', 3, 0)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (12, 12, N'qiuman', N'202cb962ac59075b964b07152d234b70', 3, 1)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (13, 13, N'sunhui', N'202cb962ac59075b964b07152d234b70', 3, 1)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (14, 14, N'zhongxiaojun', N'202cb962ac59075b964b07152d234b70', 3, 0)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (15, 15, N'wangcheng', N'202cb962ac59075b964b07152d234b70', 3, 0)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (16, 16, N'taochunsong', N'202cb962ac59075b964b07152d234b70', 3, 0)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (17, NULL, N'admin', N'202cb962ac59075b964b07152d234b70', 0, 0)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (22, 17, N'zouzhichao', N'202cb962ac59075b964b07152d234b70', 3, 0)
INSERT [dbo].[T_user] ([id], [eid], [loginname], [password], [userlevel], [isdelete]) VALUES (23, 20, N'', N'202cb962ac59075b964b07152d234b70', 1, 0)
SET IDENTITY_INSERT [dbo].[T_user] OFF
SET IDENTITY_INSERT [dbo].[T_xzjx] ON 

INSERT [dbo].[T_xzjx] ([id], [applymonth], [attachcontent]) VALUES (1, CAST(0xC8390B00 AS Date), N'123')
INSERT [dbo].[T_xzjx] ([id], [applymonth], [attachcontent]) VALUES (2, CAST(0xC8390B00 AS Date), N'1')
INSERT [dbo].[T_xzjx] ([id], [applymonth], [attachcontent]) VALUES (3, CAST(0xC8390B00 AS Date), N'<p>435679803124987</p><table><tbody><tr class="firstRow"><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="268">王二<br/></td><td style="border:1px solid #ccc;" valign="top" width="268"><br/></td><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="268">；林肯郡<br/></td></tr><tr><td style="border:1px solid #ccc;" valign="top" width="268"><br/></td><td style="border: 1px solid rgb(204, 204, 204); word-break: break-all;" valign="top" width="268">撒旦法规范化<br/></td><td style="border:1px solid #ccc;" valign="top" width="268"><br/></td></tr><tr><td style="border:1px solid #ccc;" valign="top" width="268"><br/></td><td style="border:1px solid #ccc;" valign="top" width="268"><br/></td><td style="border:1px solid #ccc;" valign="top" width="268"><br/></td></tr></tbody></table><p><br/></p>')
SET IDENTITY_INSERT [dbo].[T_xzjx] OFF
SET ANSI_PADDING ON

GO
/****** Object:  Index [UQ_T_department_name]    Script Date: 2015/5/7 6:55:00 ******/
ALTER TABLE [dbo].[T_department] ADD  CONSTRAINT [UQ_T_department_name] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [UQ_T_flowname_flowname]    Script Date: 2015/5/7 6:55:00 ******/
ALTER TABLE [dbo].[T_flowname] ADD  CONSTRAINT [UQ_T_flowname_flowname] UNIQUE NONCLUSTERED 
(
	[flowname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [UQ_T_position_name]    Script Date: 2015/5/7 6:55:00 ******/
ALTER TABLE [dbo].[T_position] ADD  CONSTRAINT [UQ_T_position_name] UNIQUE NONCLUSTERED 
(
	[pname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [UQ_T_user_loginname]    Script Date: 2015/5/7 6:55:00 ******/
ALTER TABLE [dbo].[T_user] ADD  CONSTRAINT [UQ_T_user_loginname] UNIQUE NONCLUSTERED 
(
	[loginname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_employee] ADD  CONSTRAINT [DF_T_employee_isonjob]  DEFAULT ((1)) FOR [isonjob]
GO
ALTER TABLE [dbo].[T_fybx] ADD  CONSTRAINT [DF_T_fybx_prepay]  DEFAULT ((0)) FOR [prepay]
GO
ALTER TABLE [dbo].[T_fybx] ADD  CONSTRAINT [DF_T_fybx_returnpay]  DEFAULT ((0)) FOR [returnpay]
GO
ALTER TABLE [dbo].[T_fybx] ADD  CONSTRAINT [DF_T_fybx_attachpath]  DEFAULT ('') FOR [attachpath]
GO
ALTER TABLE [dbo].[T_log] ADD  CONSTRAINT [DF_T_log_id]  DEFAULT (newid()) FOR [id]
GO
ALTER TABLE [dbo].[T_user] ADD  CONSTRAINT [DF_T_user_password]  DEFAULT (N'202cb962ac59075b964b07152d234b70') FOR [password]
GO
ALTER TABLE [dbo].[T_user] ADD  CONSTRAINT [DF_T_user_isdelete]  DEFAULT ((0)) FOR [isdelete]
GO
ALTER TABLE [dbo].[T_flowname]  WITH CHECK ADD  CONSTRAINT [FK_T_flowname_T_flowname] FOREIGN KEY([id])
REFERENCES [dbo].[T_flowname] ([id])
GO
ALTER TABLE [dbo].[T_flowname] CHECK CONSTRAINT [FK_T_flowname_T_flowname]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T_agency"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 146
               Right = 185
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "e1"
            Begin Extent = 
               Top = 73
               Left = 246
               Bottom = 213
               Right = 417
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "e2"
            Begin Extent = 
               Top = 6
               Left = 432
               Bottom = 146
               Right = 603
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1110
         Alias = 1380
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_agencylist'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_agencylist'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[38] 4[13] 2[38] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T_formflow"
            Begin Extent = 
               Top = 0
               Left = 0
               Bottom = 271
               Right = 157
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_flow"
            Begin Extent = 
               Top = 0
               Left = 196
               Bottom = 189
               Right = 334
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T_employee"
            Begin Extent = 
               Top = 0
               Left = 377
               Bottom = 181
               Right = 533
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_position"
            Begin Extent = 
               Top = 0
               Left = 609
               Bottom = 122
               Right = 752
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_department"
            Begin Extent = 
               Top = 125
               Left = 598
               Bottom = 246
               Right = 754
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_position_1"
            Begin Extent = 
               Top = 193
               Left = 224
               Bottom = 314
               Right = 364
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_employee_1"
            Begin Extent = 
               Top = 198
               Left = 391
               Bottom = 332
               Right = 577
            End
           ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_baseinfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_state"
            Begin Extent = 
               Top = 276
               Left = 38
               Bottom = 378
               Right = 182
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 2100
         Table = 1815
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_baseinfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_baseinfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[44] 4[21] 2[23] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T_employee"
            Begin Extent = 
               Top = 0
               Left = 211
               Bottom = 206
               Right = 368
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_position"
            Begin Extent = 
               Top = 107
               Left = 417
               Bottom = 229
               Right = 562
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_department"
            Begin Extent = 
               Top = 0
               Left = 0
               Bottom = 124
               Right = 153
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_user"
            Begin Extent = 
               Top = 0
               Left = 569
               Bottom = 179
               Right = 703
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1620
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_employee'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_employee'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[44] 4[18] 2[26] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T_employee"
            Begin Extent = 
               Top = 14
               Left = 236
               Bottom = 205
               Right = 407
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_position"
            Begin Extent = 
               Top = 100
               Left = 436
               Bottom = 221
               Right = 593
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_department"
            Begin Extent = 
               Top = 0
               Left = 5
               Bottom = 121
               Right = 173
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_position_1"
            Begin Extent = 
               Top = 121
               Left = 3
               Bottom = 242
               Right = 160
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_user"
            Begin Extent = 
               Top = 0
               Left = 597
               Bottom = 181
               Right = 747
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
     ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_employeeuser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'    Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_employeeuser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_employeeuser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[36] 4[28] 2[19] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T_option"
            Begin Extent = 
               Top = 0
               Left = 0
               Bottom = 180
               Right = 157
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_employee"
            Begin Extent = 
               Top = 0
               Left = 204
               Bottom = 183
               Right = 375
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_result"
            Begin Extent = 
               Top = 75
               Left = 514
               Bottom = 177
               Right = 668
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_examinfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_examinfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[35] 4[23] 2[25] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T_employee"
            Begin Extent = 
               Top = 0
               Left = 333
               Bottom = 183
               Right = 504
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_user"
            Begin Extent = 
               Top = 0
               Left = 0
               Bottom = 177
               Right = 150
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 3150
         Alias = 1335
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_login'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_login'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[37] 4[26] 2[22] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1[50] 4[25] 3) )"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -192
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T_formflow"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 203
               Right = 207
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T_flow"
            Begin Extent = 
               Top = 6
               Left = 245
               Bottom = 146
               Right = 396
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_employee"
            Begin Extent = 
               Top = 6
               Left = 434
               Bottom = 186
               Right = 605
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_position"
            Begin Extent = 
               Top = 158
               Left = 270
               Bottom = 279
               Right = 427
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "se"
            Begin Extent = 
               Top = 186
               Left = 465
               Bottom = 326
               Right = 636
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 1560
         Table = 1650
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_nextsignlist'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_nextsignlist'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_nextsignlist'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[17] 2[31] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1[50] 4[25] 3) )"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -192
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T_formflow"
            Begin Extent = 
               Top = 198
               Left = 38
               Bottom = 398
               Right = 195
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_flow"
            Begin Extent = 
               Top = 198
               Left = 233
               Bottom = 338
               Right = 384
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_position"
            Begin Extent = 
               Top = 224
               Left = 401
               Bottom = 348
               Right = 558
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_employee"
            Begin Extent = 
               Top = 266
               Left = 625
               Bottom = 406
               Right = 796
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_state"
            Begin Extent = 
               Top = 198
               Left = 617
               Bottom = 300
               Right = 761
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 3150
         Alias = 1080
         Table = 1575
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
   ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_ownwrittenlist'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'      Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_ownwrittenlist'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_ownwrittenlist'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T_formflow"
            Begin Extent = 
               Top = 0
               Left = 0
               Bottom = 206
               Right = 156
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T_flow"
            Begin Extent = 
               Top = 0
               Left = 338
               Bottom = 188
               Right = 477
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1200
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_premaininfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_premaininfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[24] 2[21] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1[50] 4[25] 3) )"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T_formflow"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 146
               Right = 195
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_flow"
            Begin Extent = 
               Top = 6
               Left = 233
               Bottom = 146
               Right = 384
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_employee"
            Begin Extent = 
               Top = 6
               Left = 422
               Bottom = 146
               Right = 593
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_state"
            Begin Extent = 
               Top = 6
               Left = 631
               Bottom = 108
               Right = 775
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_option"
            Begin Extent = 
               Top = 150
               Left = 38
               Bottom = 290
               Right = 195
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1650
         Alias = 1635
         Table = 1335
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 135' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_recordsignlist'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'0
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_recordsignlist'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_recordsignlist'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T_formflow"
            Begin Extent = 
               Top = 0
               Left = 34
               Bottom = 212
               Right = 191
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_fieldtype"
            Begin Extent = 
               Top = 5
               Left = 502
               Bottom = 171
               Right = 648
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_jb"
            Begin Extent = 
               Top = 0
               Left = 295
               Bottom = 208
               Right = 442
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_stajb'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_stajb'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T_formflow"
            Begin Extent = 
               Top = 0
               Left = 34
               Bottom = 212
               Right = 191
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T_qj"
            Begin Extent = 
               Top = 6
               Left = 233
               Bottom = 212
               Right = 380
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T_fieldtype"
            Begin Extent = 
               Top = 74
               Left = 447
               Bottom = 195
               Right = 593
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_staqj'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_staqj'
GO
USE [master]
GO
ALTER DATABASE [TL_CMS] SET  READ_WRITE 
GO

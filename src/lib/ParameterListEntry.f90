
module ParameterListEntry

USE IR_Precision 
USE LinkedList
USE DimensionsWrapper

implicit none
private

    type, extends(LinkedList_t) :: ParameterListEntry_t
    private
        class(DimensionsWrapper_t), allocatable :: Value
    contains
    private
        procedure         ::                  ParameterListEntry_AddNode
        procedure, public :: Free          => ParameterListEntry_Free
        procedure, public :: Print         => ParameterListEntry_Print
        procedure, public :: HasValue      => ParameterListEntry_HasValue
        procedure, public :: SetValue      => ParameterListEntry_SetValue
        procedure, public :: GetValue      => ParameterListEntry_GetValue
        procedure, public :: PointToValue  => ParameterListEntry_PointToValue
        procedure, public :: RemoveNode    => ParameterListEntry_RemoveNode
        generic,   public :: AddNode       => ParameterListEntry_AddNode     
        final             ::                  ParameterListEntry_Finalize 
    end type ParameterListEntry_t

public :: ParameterListEntry_t

contains


    function ParameterListEntry_HasValue(this) result(hasValue)
    !-----------------------------------------------------------------
    !< Check if Value is allocated for the current Node
    !-----------------------------------------------------------------
        class(ParameterListEntry_t), intent(IN) :: this               !< Parameter List 
        logical                                 :: hasValue           !< Check if Value is allocated
    !-----------------------------------------------------------------
        hasValue = allocated(this%Value)
    end function ParameterListEntry_HasValue


    subroutine ParameterListEntry_SetValue(this, Value)
    !-----------------------------------------------------------------
    !< Set a concrete Wrapper
    !-----------------------------------------------------------------
        class(ParameterListEntry_t),          intent(INOUT)  :: this  !< Parameter List
        class(DimensionsWrapper_t),           intent(IN)     :: Value !< Concrete Wrapper
    !-----------------------------------------------------------------
        if(this%HasValue()) deallocate(this%Value)
        allocate(this%Value, source=Value)
    end subroutine ParameterListEntry_SetValue


    subroutine ParameterListEntry_GetValue(this, Value)
    !-----------------------------------------------------------------
    !< Return a concrete WrapperFactory
    !-----------------------------------------------------------------
        class(ParameterListEntry_t),             intent(IN)  :: this  !< Parameter List
        class(DimensionsWrapper_t), allocatable, intent(OUT) :: Value !< Concrete Wrapper
    !-----------------------------------------------------------------
        if(this%HasValue()) allocate(Value, source=this%Value)
    end subroutine ParameterListEntry_GetValue


    function ParameterListEntry_PointToValue(this) result(Value)
    !-----------------------------------------------------------------
    !< Return a pointer to a concrete WrapperFactory
    !-----------------------------------------------------------------
        class(ParameterListEntry_t), target, intent(IN)  :: this      !< Parameter List
        class(DimensionsWrapper_t), pointer              :: Value     !< Concrete Wrapper
    !-----------------------------------------------------------------
        Value => this%Value
    end function ParameterListEntry_PointToValue


    recursive subroutine ParameterListEntry_Free(this)
    !-----------------------------------------------------------------
    !< Free the list
    !-----------------------------------------------------------------
        class(ParameterListEntry_t), intent(INOUT):: this             !< Parameter List 
    !-----------------------------------------------------------------
        call this%LinkedList_t%Free()
        if (this%HasValue())   deallocate(this%Value)
    end subroutine ParameterListEntry_Free


    recursive subroutine ParameterListEntry_Finalize(this)
    !-----------------------------------------------------------------
    !< Finalize procedure
    !-----------------------------------------------------------------
        type(ParameterListEntry_t), intent(INOUT):: this              !< Parameter List 
    !-----------------------------------------------------------------
        call this%Free()
    end subroutine ParameterListEntry_Finalize


    recursive subroutine ParameterListEntry_AddNode(this,Key, Value)
    !-----------------------------------------------------------------
    !< Add a new Node if key does not Exist
    !-----------------------------------------------------------------
        class(ParameterListEntry_T),          intent(INOUT) :: this   !< Linked List
        character(len=*),                     intent(IN)    :: Key    !< Key (unique) of the current node.
        class(DimensionsWrapper_t),           intent(IN)    :: Value  !< Wrapper Factory
    !-----------------------------------------------------------------
        if (this%HasKey()) then
            if (this%GetKey()/=Key) then
                if (.not. this%hasNext()) then
                    allocate(ParameterListEntry_t::this%Next)
                    select type (Next => this%Next)
                    type is (ParameterListEntry_t)
                        call Next%AddNode(Key=Key, Value=Value)
                    end select
                else
                    select type (Next => this%Next)
                    type is (ParameterListEntry_t)
                        call Next%AddNode(Key=Key, Value=Value)
                    end select
                endif
            else
                call this%SetValue(Value=Value)
            endif
        else
            call this%SetKey(Key=Key)
            call this%SetValue(Value=Value)
        endif
    end subroutine ParameterListEntry_AddNode


    subroutine ParameterListEntry_RemoveNode(this, Key)
    !-----------------------------------------------------------------
    !< Remove an LinkedList given a Key
    !-----------------------------------------------------------------
    class(ParameterListEntry_t), target, intent(INOUT) :: this        !< Parameter List
    character(len=*),                    intent(IN)    :: Key         !< String Key
    class(ParameterListEntry_t),  pointer              :: CurrentNode !< Pointer to the current Parameter List
    class(ParameterListEntry_t),  pointer              :: NextNode    !< Pointer to a next Parameter List
    class(*),                     pointer              :: AuxPointer  !< Aux pointer
    !-----------------------------------------------------------------
    nullify(NextNode)
    CurrentNode => this
    do while(associated(CurrentNode))
        select type (AuxPointer => CurrentNode%GetNext())
            type is (ParameterListEntry_t)
                NextNode => AuxPointer
            class Default
                Nullify(NextNode)
        end select
        if (CurrentNode%HasKey()) then
            if (CurrentNode%GetKey()==Key) then
                call CurrentNode%DeallocateKey()
                if (CurrentNode%HasValue()) deallocate(CurrentNode%Value)
                if (associated(NextNode)) then
                    if (NextNode%HasKey()) call CurrentNode%SetKey(Key=NextNode%GetKey())
                    if (NextNode%HasValue()) call CurrentNode%SetValue(Value=NextNode%Value)
                else
                    call CurrentNode%NullifyNext()
                endif
                exit
            endif
        endif
        CurrentNode => NextNode
    enddo
    end subroutine ParameterListEntry_RemoveNode


    recursive subroutine ParameterListEntry_Print(this, unit, prefix, iostat, iomsg)
    !-----------------------------------------------------------------
    !< Print the keys/value pair contained in the parameter list
    !-----------------------------------------------------------------
        class(ParameterListEntry_t),      intent(IN), target  :: this !< Parameter list
        integer(I4P),                     intent(IN)  :: unit         !< Logic unit.
        character(*), optional,           intent(IN)  :: prefix       !< Prefixing string.
        integer(I4P), optional,           intent(OUT) :: iostat       !< IO error.
        character(*), optional,           intent(OUT) :: iomsg        !< IO error message.
        character(len=:), allocatable                 :: prefd        !< Prefixing string.
        integer(I4P)                                  :: iostatd      !< IO error.
        character(500)                                :: iomsgd       !< Temporary variable for IO error message.
        class(ParameterListEntry_t), pointer          :: Node         !< Pointer for scanning the list.
        class(*), pointer                             :: Next         !< Pointer for scanning the list.
    !-----------------------------------------------------------------
        prefd = '' ; if (present(prefix)) prefd = prefix
        Node => this
        if(Node%HasKey()) then
            write(unit=unit,fmt='(A,$)',iostat=iostatd,iomsg=iomsgd)prefd//' Key = "'//Node%GetKey()//'", '
            call Node%Value%Print(unit=unit)
            if (Node%HasNext()) then
                Next => Node%GetNext()
                select type (Next)
                    class is (ParameterListEntry_t)
                        call Next%Print(unit=unit,prefix=prefd,iostat=iostatd,iomsg=iomsgd)
                end select
            endif
        endif
        if (present(iostat)) iostat = iostatd
        if (present(iomsg))  iomsg  = iomsgd
    end subroutine ParameterListEntry_Print


end module ParameterListEntry

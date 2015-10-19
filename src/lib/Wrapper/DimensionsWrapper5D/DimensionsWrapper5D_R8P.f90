module DimensionsWrapper5D_R8P

USE DimensionsWrapper5D
USE IR_Precision, only: R8P

implicit none
private

    type, extends(DimensionsWrapper5D_t) :: DimensionsWrapper5D_R8P_t
        real(R8P), allocatable :: Value(:,:,:,:,:)
    contains
    private
        procedure         ::                 DimensionsWrapper5D_R8P_Set
        procedure         ::                 DimensionsWrapper5D_R8P_Get
        generic,   public :: Set          => DimensionsWrapper5D_R8P_Set
        generic,   public :: Get          => DimensionsWrapper5D_R8P_Get
        procedure, public :: isOfDataType => DimensionsWrapper5D_R8P_isOfDataType
        procedure, public :: Free         => DimensionsWrapper5D_R8P_Free
        final             ::                 DimensionsWrapper5D_R8P_Final
    end type           

public :: DimensionsWrapper5D_R8P_t

contains


    subroutine DimensionsWrapper5D_R8P_Final(this) 
    !-----------------------------------------------------------------
    !< Final procedure of DimensionsWrapper5D
    !-----------------------------------------------------------------
        type(DimensionsWrapper5D_R8P_t), intent(INOUT) :: this
    !-----------------------------------------------------------------
        call this%Free()
    end subroutine


    subroutine DimensionsWrapper5D_R8P_Set(this, Value) 
    !-----------------------------------------------------------------
    !< Set R8P Wrapper Value
    !-----------------------------------------------------------------
        class(DimensionsWrapper5D_R8P_t), intent(INOUT) :: this
        class(*),                         intent(IN)    :: Value(:,:,:,:,:)
    !-----------------------------------------------------------------
        select type (Value)
            type is (real(R8P))
                allocate(this%Value(size(Value,dim=1),  &
                                    size(Value,dim=2),  &
                                    size(Value,dim=3),  &
                                    size(Value,dim=4),  &
                                    size(Value,dim=5)), &
                                    source=Value)
        end select
    end subroutine


    subroutine DimensionsWrapper5D_R8P_Get(this, Value) 
    !-----------------------------------------------------------------
    !< Get R8P Wrapper Value
    !-----------------------------------------------------------------
        class(DimensionsWrapper5D_R8P_t), intent(IN)  :: this
        real(R8P), allocatable,           intent(OUT) :: Value(:,:,:,:,:)
    !-----------------------------------------------------------------
        allocate(Value(size(this%Value,dim=1),  &
                       size(this%Value,dim=2),  &
                       size(this%Value,dim=3),  &
                       size(this%Value,dim=4),  &
                       size(this%Value,dim=5)), &
                       source=this%Value)
    end subroutine


    subroutine DimensionsWrapper5D_R8P_Free(this) 
    !-----------------------------------------------------------------
    !< Free a DimensionsWrapper5D
    !-----------------------------------------------------------------
        class(DimensionsWrapper5D_R8P_t), intent(INOUT) :: this
    !-----------------------------------------------------------------
        if(allocated(this%Value)) deallocate(this%Value)
    end subroutine


    function DimensionsWrapper5D_R8P_isOfDataType(this, Mold) result(isOfDataType)
    !-----------------------------------------------------------------
    !< Check if Mold and Value are of the same datatype 
    !-----------------------------------------------------------------
        class(DimensionsWrapper5D_R8P_t), intent(IN) :: this          !< Dimensions wrapper 5D
        class(*),                         intent(IN) :: Mold          !< Mold for data type comparison
        logical                                      :: isOfDataType  !< Boolean flag to check if Value is of the same data type as Mold
    !-----------------------------------------------------------------
        isOfDataType = .false.
        select type (Mold)
            type is (real(R8P))
                isOfDataType = .true.
        end select
    end function DimensionsWrapper5D_R8P_isOfDataType

end module DimensionsWrapper5D_R8P

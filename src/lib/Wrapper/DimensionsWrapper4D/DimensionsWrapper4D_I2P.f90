module DimensionsWrapper4D_I2P

USE DimensionsWrapper4D
USE IR_Precision, only: I2P

implicit none
private

    type, extends(DimensionsWrapper4D_t) :: DimensionsWrapper4D_I2P_t
        integer(I2P), allocatable :: Value(:,:,:,:)
    contains
    private
        procedure         ::                 DimensionsWrapper4D_I2P_Set
        procedure         ::                 DimensionsWrapper4D_I2P_Get
        generic,   public :: Set          => DimensionsWrapper4D_I2P_Set
        generic,   public :: Get          => DimensionsWrapper4D_I2P_Get
        procedure, public :: isOfDataType => DimensionsWrapper4D_I2P_isOfDataType
        procedure, public :: Free         => DimensionsWrapper4D_I2P_Free
        final             ::                 DimensionsWrapper4D_I2P_Final
    end type           

public :: DimensionsWrapper4D_I2P_t

contains


    subroutine DimensionsWrapper4D_I2P_Final(this) 
    !-----------------------------------------------------------------
    !< Final procedure of DimensionsWrapper4D
    !-----------------------------------------------------------------
        type(DimensionsWrapper4D_I2P_t), intent(INOUT) :: this
    !-----------------------------------------------------------------
        call this%Free()
    end subroutine


    subroutine DimensionsWrapper4D_I2P_Set(this, Value) 
    !-----------------------------------------------------------------
    !< Set I2P Wrapper Value
    !-----------------------------------------------------------------
        class(DimensionsWrapper4D_I2P_t), intent(INOUT) :: this
        class(*),                         intent(IN)    :: Value(:,:,:,:)
    !-----------------------------------------------------------------
        select type (Value)
            type is (integer(I2P))
                allocate(this%Value(size(Value,dim=1),  &
                                    size(Value,dim=2),  &
                                    size(Value,dim=3),  &
                                    size(Value,dim=4)), &
                                    source=Value)
        end select
    end subroutine


    subroutine DimensionsWrapper4D_I2P_Get(this, Value) 
    !-----------------------------------------------------------------
    !< Get I2P Wrapper Value
    !-----------------------------------------------------------------
        class(DimensionsWrapper4D_I2P_t), intent(IN)  :: this
        integer(I2P), allocatable,        intent(OUT) :: Value(:,:,:,:)
    !-----------------------------------------------------------------
        allocate(Value(size(this%Value,dim=1),  &
                       size(this%Value,dim=2),  &
                       size(this%Value,dim=3),  &
                       size(this%Value,dim=4)), &
                       source=this%Value)
    end subroutine


    subroutine DimensionsWrapper4D_I2P_Free(this) 
    !-----------------------------------------------------------------
    !< Free a DimensionsWrapper4D
    !-----------------------------------------------------------------
        class(DimensionsWrapper4D_I2P_t), intent(INOUT) :: this
    !-----------------------------------------------------------------
        if(allocated(this%Value)) deallocate(this%Value)
    end subroutine


    function DimensionsWrapper4D_I2P_isOfDataType(this, Mold) result(isOfDataType)
    !-----------------------------------------------------------------
    !< Check if Mold and Value are of the same datatype 
    !-----------------------------------------------------------------
        class(DimensionsWrapper4D_I2P_t), intent(IN) :: this          !< Dimensions wrapper 4D
        class(*),                         intent(IN) :: Mold          !< Mold for data type comparison
        logical                                      :: isOfDataType  !< Boolean flag to check if Value is of the same data type as Mold
    !-----------------------------------------------------------------
        isOfDataType = .false.
        select type (Mold)
            type is (integer(I2P))
                isOfDataType = .true.
        end select
    end function DimensionsWrapper4D_I2P_isOfDataType

end module DimensionsWrapper4D_I2P

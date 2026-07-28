from functools import wraps
from fastapi import HTTPException, status, Depends
from app.core.security import get_current_admin

ROLE_ADMIN = "admin"
ROLE_EU_ADMIN = "end_user_admin"
ROLE_ML_USER = "ml_user"


def require_roles(*allowed_roles: str):
    """
    FastAPI dependency factory.
    Usage:  Depends(require_roles("admin", "end_user_admin"))
    """
    async def _checker(current: dict = Depends(get_current_admin)):
        if current.get("role") not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Role '{current.get('role')}' is not permitted for this action.",
            )
        return current
    return _checker


# Pre-built dependency shortcuts
admin_only      = require_roles(ROLE_ADMIN)
eu_admin_access = require_roles(ROLE_ADMIN, ROLE_EU_ADMIN)
data_access     = require_roles(ROLE_ADMIN, ROLE_ML_USER)
any_admin       = require_roles(ROLE_ADMIN, ROLE_EU_ADMIN, ROLE_ML_USER)

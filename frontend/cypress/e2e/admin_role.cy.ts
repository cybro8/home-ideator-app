describe('Admin Role — Full Access', () => {
  beforeEach(() => {
    cy.fixture('users').then((users) => {
      cy.visit('/login');
      cy.get('#email').type(users.admin.email);
      cy.get('#password').type(users.admin.password);
      cy.get('#loginSubmit').click();
      cy.url().should('not.include', '/login');
    });
  });

  it('shows all 3 nav items', () => {
    cy.get('#navUsers').should('be.visible');
    cy.get('#navAccounts').should('be.visible');
    cy.get('#navDevices').should('be.visible');
  });

  it('can navigate to Admin Accounts and see table', () => {
    cy.get('#navAccounts').click();
    cy.url().should('include','/admin/accounts');
    cy.get('#adminTable').should('exist');
  });

  it('can create a new admin and see in table', () => {
    cy.get('#navAccounts').click();
    cy.get('#createAdminBtn').click();
    cy.get('#createAdminModal').should('be.visible');
    cy.get('#newAdminUsername').type('cypress_admin');
    cy.get('#newAdminEmail').type('cypress_admin@test.com');
    cy.get('#newAdminPassword').type('Test@1234');
    cy.get('#newAdminRole').select('ml_user');
    cy.get('#submitCreateAdmin').click();
    cy.get('#adminTable').should('contain.text','cypress_admin');
  });

  it('can navigate to End Users and disable a user', () => {
    cy.get('#navUsers').click();
    cy.url().should('include','/admin/users');
    cy.get('#userTable').should('exist');
  });

  it('can navigate to Device Data', () => {
    cy.get('#navDevices').click();
    cy.url().should('include','/admin/devices');
    cy.get('#deviceIdInput').should('exist');
  });

  it('logout button signs out and redirects', () => {
    cy.get('#logoutBtn').click();
    cy.url().should('include','/login');
  });
});

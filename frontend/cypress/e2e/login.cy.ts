describe('Login Flow', () => {
  beforeEach(() => cy.visit('/login'));

  it('renders email + password fields and submit button', () => {
    cy.get('#email').should('exist');
    cy.get('#password').should('exist');
    cy.get('#loginSubmit').should('exist');
  });

  it('shows validation messages on blank submit', () => {
    cy.get('#loginSubmit').click();
    cy.get('.err').should('be.visible');
  });

  it('shows error toast on wrong credentials', () => {
    cy.get('#email').type('wrong@test.com');
    cy.get('#password').type('wrongpass');
    cy.get('#loginSubmit').click();
    cy.get('.err.global').should('contain.text','Invalid');
  });

  it('redirects to dashboard on valid admin login', () => {
    cy.fixture('users').then((users) => {
      cy.get('#email').type(users.admin.email);
      cy.get('#password').type(users.admin.password);
      cy.get('#loginSubmit').click();
      cy.url().should('not.include','/login');
    });
  });
});
